import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wheelwise/components/form/types/CameraSectionPage.dart';
import 'package:wheelwise/utils/const.dart';

import 'CameraScreen.dart';
import 'helpers/FormEntryWidget.dart';
import 'helpers/FormSectionHeader.dart';

class CustomForm extends StatefulWidget {
  final String formId; // Form ID passed to the widget
  final dynamic inspection;
  final String subType;
  final String type;

  const CustomForm(
      {super.key,
      required this.formId,
      required this.inspection,
      required this.subType,
      required this.type});

  @override
  State<CustomForm> createState() => _CustomFormState();
}

class _CustomFormState extends State<CustomForm> {
  var formData;
  int page = 0;
  int sectionNumber = 0;
  List<dynamic> sectionsInForm = [];
  Map<String, dynamic> formState = {}; // To store form answers

  @override
  void initState() {
    super.initState();
    initializeForm();
  }

  Future<void> initializeForm() async {
    await loadData();
    await skipCompletedSections();
  }

  Future<void> skipCompletedSections() async {
    final storage = await SharedPreferences.getInstance();

    // bool res = await storage.clear();
    String? formDataString = storage.getString(widget.formId);

    if (formDataString != null) {
      Map<String, dynamic> savedData = jsonDecode(formDataString);
      int sectionNum = -1;

      // Check which sections have data
      for (int i = 0; i < sectionsInForm.length; i++) {
        String sectionKey = sectionsInForm[i];
        List<dynamic> formResponses =
            savedData['content']['form-responses'] ?? [];

        // Check if any response matches the current sectionKey
        bool sectionExists = formResponses.any((response) {
          // Check if the section exists and matches the structure
          if (response.containsKey(sectionKey)) {
            var sectionData = response[sectionKey];
            // Check if it's a list or an object and validate non-emptiness
            if (sectionData is List && sectionData.isNotEmpty) {
              return true;
            } else if (sectionData is Map && sectionData.isNotEmpty) {
              return true;
            }
          }
          return false;
        });
        // If the section doesn't exist, set sectionNumber
        if (!sectionExists) {
          setState(() {
            sectionNum = i;
            sectionNumber = i;
          });
          break;
        }
      }

      if (sectionNum == -1) {
        setState(() {
          sectionNum = 0;
        });
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CameraScreen(
              formId: widget.formId,
            ),
          ),
        );
      }
    }
  }

  Future<void> appendSectionToFormResponses(
      Map<String, dynamic> currentSectionData, String formId) async {
    final storage = await SharedPreferences.getInstance();

    // Retrieve existing form data
    String? formDataString = storage.getString(formId);

    Map<String, dynamic> formData = formDataString != null
        ? jsonDecode(formDataString)
        : {
            "content": {
              "form-responses": [],
              "media": {
                "sectionImages": [
                  {
                    "section": "string",
                    "images": [
                      {"url": "string", "description": "string"}
                    ]
                  }
                ],
                "vehicalmedia": {
                  "images":[],
                  "videos":[]
                }
            },
          }
          };

    // Transform current section data
    List<dynamic> transformedSection =
        currentSectionData["questions"]?.map((entry) {
      return {
        "What to Check": entry["whatToCheck"],
        "Description": entry["description"],
        "response": entry["response"],
        "rating": entry["rating"],
      };
    }).toList();

    // Append to form-responses
    formData['content']['form-responses'].add({
      sectionsInForm[sectionNumber]: transformedSection,
    });

    // // Save back to storage
    await storage.setString(formId, jsonEncode(formData));
  }

  Future<void> loadData() async {
    String jsonString = await rootBundle
        .loadString(FormsConfig().forms[widget.type]![widget.subType]!);
    var data = jsonDecode(jsonString);

    setState(() {
      sectionsInForm = data['sections'];

      formData = data;
      for (var section in sectionsInForm) {
        if (data[section] != null) {
          formState[section] = {
            "questions": data[section].map((entry) {
              return {
                "description": entry["Description"] ?? "",
                "whatToCheck": entry["What to Check"] ?? "",
                "options": entry["parameters"]
                    ?.map<Map<String, String>>((param) => {
                          "condition": param["condition"]?.toString() ?? "",
                          "rating": param["rating"]?.toString() ?? "",
                        })
                    ?.toList(),
                "response": "",
                "rating": ""
              };
            }).toList(),
          };
        }
      }
    });
  }

  List<dynamic> getEntriesForCurrentSection() {
    String currentSection = sectionsInForm[sectionNumber];
    return formState[currentSection]["questions"] ?? [];
  }

  bool isSectionComplete(String section) {
    List<dynamic> questions = formState[section]["questions"] ?? [];
    return questions.every((entry) => entry["response"] != "");
  }

  bool areAllSectionsComplete() {
    return sectionsInForm.every((section) => isSectionComplete(section));
  }

  void saveToLocalMemory() async {
    final storage = await SharedPreferences.getInstance();
    await storage.setString('formData', jsonEncode(formState));
  }

  void moveToPreviousPageOrSection() {
    if (page > 0) {
      setState(() {
        page--;
      });
    } else if (sectionNumber > 0) {
      setState(() {
        sectionNumber--;
        page = (getEntriesForCurrentSection().length - 1) ~/
            10; // Calculate the last page of the previous section
      });
    } else {}
  }

  void removeOptionsFromData(Map<String, dynamic> data) {
    data.forEach((sectionKey, sectionValue) {
      // Iterate over the questions in the section
      if (sectionValue is Map && sectionValue['questions'] is List) {
        for (var question in sectionValue['questions']) {
          // Remove the options key from each question
          if (question is Map && question.containsKey('options')) {
            question.remove('options');
          }
        }
      }
    });
  }

  proceedToCameraforsection() async {
    saveToLocalMemory();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CameraSectionPage(
          sectionName:
              sectionsInForm[sectionNumber], // Pass the current section name
          formId: widget.formId, // Pass the current section name
        ),
      ),
    ).then((_) {
      if(sectionNumber == sectionsInForm.length-1){
        proceedToCamera();
      }
      setState(() {
        sectionNumber++; // Move to the next section
        page = 0; // Reset page when moving to the next section
      });
    });
  }

  void moveToNextPageOrSection() async {
    List<dynamic> currentSectionEntries = getEntriesForCurrentSection();
    int totalEntries = currentSectionEntries.length;

    if (page * 10 + 10 >= totalEntries) {
      if (isSectionComplete(sectionsInForm[sectionNumber])) {
        await appendSectionToFormResponses(
            formState[sectionsInForm[sectionNumber]], widget.formId);

        if (sectionNumber < sectionsInForm.length - 1) {
          await proceedToCameraforsection();
        } else {
          await proceedToCameraforsection();
        }
      } else {
        showIncompleteSectionAlert();
      }
    } else {
      setState(() {
        page++;
      });
    }
  }

  void showIncompleteSectionAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Incomplete Section"),
        content: const Text(
            "Please complete all questions in the current section before proceeding."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void proceedToCamera() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => CameraScreen(
                formId: widget.formId,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (formData == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    List<dynamic> currentSectionEntries = getEntriesForCurrentSection();
    int totalEntries = currentSectionEntries.length;
    List<dynamic> entriesToShow =
        currentSectionEntries.skip(page * 10).take(10).toList();

    return Scaffold(
      // appBar: AppBar(title: const Text('128 Points Inspection')),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  FormSectionHeader(
                      title: sectionsInForm[sectionNumber],
                      carName: widget.inspection['vehicleInfo']['model'],
                      subType:
                          '${widget.inspection['inspectionType']} - ${widget.inspection['subType']}',
                      sectionNumber: sectionNumber,
                      totalSection: sectionsInForm.length),
                  Expanded(
                    child: ListView(
                      children: entriesToShow
                          .map(
                            (entry) => FormEntryWidget(
                              description: entry["description"],
                              whatToCheck: entry["whatToCheck"],
                              selectedValue: entry["response"],
                              parameters: entry["options"],
                              onChanged: (value, rating) {
                                // Pass both response and rating
                                setState(() {
                                  entry["response"] = value ?? "";
                                  entry["rating"] =
                                      rating ?? ""; // Store rating as well
                                });
                              },
                            ),
                          )
                          .toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (page > 0 || sectionNumber > 0)
                  GestureDetector(
                      onTap: moveToPreviousPageOrSection,
                      child: Container(
                          alignment: Alignment.topCenter,
                          width: MediaQuery.of(context).size.width * 0.2,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                              color: Color(0xFF262626),
                              border: Border.all(color: AppColors.primaryColor),
                              borderRadius: BorderRadius.circular(10)),
                          child: const Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ))),
                GestureDetector(
                    onTap: moveToNextPageOrSection,
                    child: Container(
                        alignment: Alignment.topCenter,
                        width: MediaQuery.of(context).size.width * 0.2,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            color: Color(0xFF262626),
                            border: Border.all(color: AppColors.primaryColor),
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          sectionNumber == sectionsInForm.length - 1 &&
                                  page * 10 + 10 >= totalEntries
                              ? 'Camera'
                              : 'Next',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
