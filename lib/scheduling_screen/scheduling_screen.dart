import 'package:flutter/material.dart';
import 'package:project/home_screen/home_screen.dart';
import 'package:project/post_storage/post_storage.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

class SchedulingScreen extends StatefulWidget {
  const SchedulingScreen({super.key});
  @override
  SchedulingScreenState createState() => SchedulingScreenState();
}

class SchedulingScreenState extends State<SchedulingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _timeController = TextEditingController();
  List<Map<String, String>> _postagens = [];
  String? imagePath;

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadPostagens();
  }

  _loadPostagens() async {
    final storedData = await PostStorage.loadPostagens();
    setState(() {
      _postagens = storedData;
    });
  }

  void _agendarPostagem() {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      final newPost = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': _selectedDate.toIso8601String(),
        'time': _timeController.text,
        'image': 'assets/images/image1.jpg',
      };

      setState(() {
        _postagens.add(newPost);
      });

      PostStorage.savePostagens(_postagens);
      _titleController.clear();
      _descriptionController.clear();
      _timeController.clear();
      imagePath = null;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF3B5CFF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF3B5CFF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _timeController.text = picked
            .format(context)
            .replaceAll(RegExp(r'AM|PM'), '');
      });
    }
  }

  String getFormattedDate(DateTime date) {
    final DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(date);
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _showConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String formattedDate = DateFormat('dd/MM/yyyy').format(_selectedDate);
        String time = _timeController.text;

        return AlertDialog(
          title: Text(
            "Confirmação",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Tem certeza que deseja agendar a postagem '${_titleController.text}' "
            "para $formattedDate às $time?",
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                _agendarPostagem();
                Navigator.of(context).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Postagem agendada com sucesso!'),
                    duration: Duration(seconds: 2),
                  ),
                );

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => HomeScreen()),
                );
              },
              child: Text("Confirmar"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "Agendar postagem",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        'assets/images/image1.jpg',
                        width: 120,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Image.asset(
                        'assets/images/image2.jpg',
                        width: 120,
                        height: 160,
                        fit: BoxFit.cover,
                      ),
                    ),
                    GestureDetector(
                      onTap: _pickImage,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10.0),
                        child: Container(
                          width: 120,
                          height: 160,
                          color: Colors.grey[200],
                          child: Icon(Icons.add_a_photo),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Título",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0xFF3B5CFF),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0xBCCBCBCB),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0x82CBCBCB),
                        width: 1,
                      ),
                    ),
                    filled: true,
                    fillColor: Color(0x0F37C5F8),
                  ),
                ),
                SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Legenda",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),
                TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0xFF3B5CFF),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0xBCCBCBCB),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      borderSide: BorderSide(
                        color: Color(0x82CBCBCB),
                        width: 1,
                      ),
                    ),
                    filled: true,
                    fillColor: Color(0x0F37C5F8),
                  ),
                  maxLines: 4,
                ),
                SizedBox(height: 20),

                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Agendamento",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: TextEditingController(
                          text: getFormattedDate(_selectedDate),
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color(0x0F37C5F8),
                          prefixIcon: Icon(
                            Icons.calendar_today,
                            color: Color(0xFF3B5CFF),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        readOnly: true,
                        onTap: () => _selectDate(context),
                      ),
                    ),
                    SizedBox(width: 10),

                    Expanded(
                      child: TextField(
                        controller: _timeController,
                        decoration: InputDecoration(
                          labelStyle: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color(0x0F37C5F8),
                          prefixIcon: Icon(
                            Icons.access_time,
                            color: Color(0xFF3B5CFF),
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                        readOnly: true,
                        onTap: () => _selectTime(context),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 36),

                ElevatedButton(
                  onPressed: _showConfirmationDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF3B5CFF),
                    minimumSize: Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.0),
                    ),
                  ),
                  child: Text(
                    "Agendar",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
