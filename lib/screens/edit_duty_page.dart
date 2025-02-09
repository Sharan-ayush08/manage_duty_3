import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:manage_duty_3/screens/view_duties.dart';
import 'package:provider/provider.dart';

import '../models/duty.dart';
import '../providers/my_duty.dart';

class EditDutyPage extends StatefulWidget {
  static const routeName = '/edit_duty';
  final String? dutyId = ViewDutiesPage.dutyId;

  @override
  _EditDutyPageState createState() => _EditDutyPageState();
}

class _EditDutyPageState extends State<EditDutyPage> {
  final _nameCtrlr = TextEditingController();
  final _abbCtrlr = TextEditingController();
  final _startTimeCtrlr = TextEditingController();
  final _endTimeCtrlr = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  int _selectedColor = 0;
  int _selectedButton = 0;
  var _editedDuty = Duty(
    id: null,
    dutyName: '',
    dutyAbbreviation: '',
    dutyColor: Colors.lightBlue,
    dutyStartTime: TimeOfDay(hour: 8, minute: 00),
    dutyEndTime: TimeOfDay(hour: 14, minute: 00),
  );

  var _isInit = true;
  var _isLoading = false;

  TimeOfDay selectedTime = TimeOfDay.now();

  TimeOfDay stringToTimeOfDay(String tod) {
    final format = DateFormat.jm(); //"6:00 AM"
    return TimeOfDay.fromDateTime(format.parse(tod));
  }

  Future<Null> _selectStartTime(BuildContext context) async {
    selectedTime = stringToTimeOfDay(_startTimeCtrlr.text);
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null) {
      selectedTime = pickedTime;

      DateTime parsedTime =
          DateFormat.jm().parse(pickedTime.format(context).toString());

      String formattedTime = DateFormat('hh:mm aa').format(parsedTime);
      setState(() {
        _startTimeCtrlr.text = formattedTime;
      });
    }
  }

  Future<Null> _selectEndTime(BuildContext context) async {
    selectedTime = stringToTimeOfDay(_endTimeCtrlr.text);
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (pickedTime != null) {
      selectedTime = pickedTime;

      DateTime parsedTime =
          DateFormat.jm().parse(pickedTime.format(context).toString());

      String formattedTime = DateFormat('hh:mm aa').format(parsedTime);
      setState(
        () {
          _endTimeCtrlr.text = formattedTime;
        },
      );
    }
  }

  final colors = MyDuty.colors;

  final List<String> workType = ["work", "off", "vac", "half"];

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final dutyId = ModalRoute.of(context)?.settings.arguments as String?;

      if (dutyId != null) {
        _editedDuty =
            Provider.of<MyDuty>(context, listen: false).findById(dutyId);

        _nameCtrlr.text = _editedDuty.dutyName;
        _abbCtrlr.text = _editedDuty.dutyAbbreviation;
      }
      _startTimeCtrlr.text = _editedDuty.dutyStartTime.format(context);
      _endTimeCtrlr.text = _editedDuty.dutyEndTime.format(context);
    }
    _isInit = false;
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _abbCtrlr.dispose();
    _nameCtrlr.dispose();
    _startTimeCtrlr.dispose();
    _endTimeCtrlr.dispose();
    super.dispose();
  }

  Future<void> _saveForm() async {
    final id = EditDutyPage().dutyId;
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    _editedDuty = Duty(
      id: _editedDuty.id,
      dutyName: _nameCtrlr.text,
      dutyAbbreviation: _abbCtrlr.text,
      dutyColor: colors[_selectedColor],
      dutyStartTime: stringToTimeOfDay(_startTimeCtrlr.text),
      dutyEndTime: stringToTimeOfDay(_endTimeCtrlr.text),
    );
    setState(() {
      _isLoading = true;
    });
    if (id != null) {
      await Provider.of<MyDuty>(context, listen: false)
          .updateDuty(id, _editedDuty);
      setState(() {
        _isLoading = false;
      });
      Navigator.pop(context);
    } else {
      try {
        await Provider.of<MyDuty>(context, listen: false)
            .addDuty(_editedDuty, context);
      } catch (error) {
        print(error.toString());
        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text('An error occurred!'),
            content: Text('Something went wrong'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Okay'),
              ),
            ],
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Edit Duty"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveForm,
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: SafeArea(
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      ListTile(
                        leading: Container(
                          height: double.infinity,
                          child: Icon(Icons.edit),
                        ),
                        title: TextFormField(
                            controller: _nameCtrlr,
                            decoration: InputDecoration(
                                labelText: "Duty Name",
                                border: InputBorder.none),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Please provide a Duty name.';
                              }
                              return null;
                            }),
                        trailing: Container(
                          height: 40.0,
                          width: 60.0,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            color: colors[_selectedColor],
                          ),
                          child: Center(
                            child: Text(
                              _abbCtrlr.text.isEmpty
                                  ? 'DUTY'
                                  : _abbCtrlr.text.toString(),
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: 40,
                        width: double.infinity,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: colors.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedColor = index;
                                });
                              },
                              child: Container(
                                margin: _selectedColor == index
                                    ? EdgeInsets.fromLTRB(3, 0, 3, 0)
                                    : EdgeInsets.fromLTRB(6, 5, 6, 5),
                                width: 60,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(5),
                                  border: Border.all(
                                      color: _selectedColor == index
                                          ? colors[index]
                                          : Colors.transparent,
                                      width: 4),
                                  color: colors[index],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Divider(
                        height: 30,
                        indent: 10,
                        thickness: 1,
                      ),
                      ListTile(
                        leading: Container(
                          height: double.infinity,
                          child: Icon(Icons.edit),
                        ),
                        title: TextFormField(
                          controller: _abbCtrlr,
                          onChanged: (value) {
                            setState(() {});
                          },
                          decoration: InputDecoration(
                              labelText: "ABBREVIATION",
                              border: InputBorder.none),
                        ),
                      ),
                      Divider(
                        height: 30,
                        indent: 10,
                        thickness: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 7.0),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(Icons.merge_type_outlined),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 5.0),
                              child: Text(
                                "Type",
                                style: TextStyle(fontSize: 17.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 50,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: workType.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(5.0),
                                child: RaisedButton(
                                  onPressed: () {
                                    setState(() {
                                      _selectedButton = index;
                                    });
                                  },
                                  child: Text(workType[index]),
                                  color: _selectedButton == index
                                      ? Colors.blue
                                      : Colors.white,
                                  textColor: _selectedButton == index
                                      ? Colors.white
                                      : Colors.black,
                                ),
                              );
                            }),
                      ),
                      Divider(
                        height: 30,
                        indent: 10,
                        thickness: 1,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 7.0),
                        child: Row(
                          children: <Widget>[
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Icon(Icons.timer),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: Text(
                                "Schedule",
                                style: TextStyle(fontSize: 17.0),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            width: 90,
                            child: GestureDetector(
                              child: Builder(builder: (context) {
                                return TextFormField(
                                    controller: _startTimeCtrlr,
                                    decoration: InputDecoration(
                                        labelText: "START TIME",
                                        border: InputBorder.none),
                                    readOnly: true,
                                    onTap: () {
                                      _selectStartTime(context);
                                    });
                              }),
                            ),
                          ),
                          Text(
                            ">",
                            style: TextStyle(fontSize: 30),
                          ),
                          Container(
                            width: 80,
                            child: GestureDetector(
                              child: Builder(builder: (context) {
                                return TextFormField(
                                  controller: _endTimeCtrlr,
                                  decoration: InputDecoration(
                                      labelText: "END TIME",
                                      border: InputBorder.none),
                                  readOnly: true,
                                  onTap: () {
                                    _selectEndTime(context);
                                  },
                                );
                              }),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
