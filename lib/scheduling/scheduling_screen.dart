import 'package:flutter/material.dart';
import 'package:project/features/home/presentation/home_screen.dart';
import 'package:project/data/local/post_storage.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:flutter_svg/flutter_svg.dart';

class SchedulingScreen extends StatefulWidget {
  final Map<String, String>? post; // Adiciona parâmetro para receber o post

  SchedulingScreen({super.key, this.post});

  @override
  SchedulingScreenState createState() => SchedulingScreenState();
}

class SchedulingScreenState extends State<SchedulingScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  List<Map<String, String>> _posts = [];
  String? imagePath;
  final ImagePicker _picker =
      ImagePicker(); // Adicione esta linha no início da classe SchedulingScreenState

  @override
  void initState() {
    super.initState();

    // Se estiver editando, preenche os campos com os dados do post
    if (widget.post != null) {
      _titleController.text = widget.post!['title'] ?? '';
      _descriptionController.text = widget.post!['description'] ?? '';
      if (widget.post != null && widget.post!['date'] != null) {
        _selectedDate = DateTime.parse(widget.post!['date']!);
        _dateController.text = getFormattedDate(_selectedDate);
      }
      if (widget.post!['date'] != null) {
        _selectedDate = DateTime.parse(widget.post!['date']!);
      }
      if (widget.post!['time'] != null) {
        _timeController.text = widget.post!['time']!;
      } else {
        // Caso o horário esteja embutido na data
        _timeController.text = TimeOfDay.fromDateTime(
          _selectedDate,
        ).format(context);
      }
      imagePath = widget.post!['image'];
    }

    _loadPost();
  }

  _loadPost() async {
    final storedData = await PostStorage.loadPostagens();
    setState(() {
      _posts = storedData;
    });
  }

  void _schedulePost() {
    if (_titleController.text.isNotEmpty &&
        _descriptionController.text.isNotEmpty) {
      final newPost = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': _selectedDate.toIso8601String(),
        'time': _timeController.text,
        'image': imagePath ?? 'assets/images/image1.jpg',
      };

      setState(() {
        if (widget.post != null) {
          // Atualiza o post existente
          int index = _posts.indexWhere(
            (p) =>
                p['title'] == widget.post!['title'] &&
                p['description'] == widget.post!['description'] &&
                p['date'] == widget.post!['date'] &&
                p['time'] == widget.post!['time'],
          );
          if (index != -1) {
            _posts[index] = newPost;
          }
        } else {
          // Cria novo post
          _posts.add(newPost);
        }
      });

      PostStorage.savePosts(_posts);
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
        _dateController.text = getFormattedDate(_selectedDate);
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
                _schedulePost();
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
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
                          SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.asset(
                              'assets/images/image2.jpg',
                              width: 120,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: Image.asset(
                              'assets/images/image2.jpg',
                              width: 120,
                              height: 160,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(width: 12),
                          GestureDetector(
                            onTap: _pickImage,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: Container(
                                width: 120,
                                height: 160,
                                color: Color(0x23BFBFBF),
                                child:
                                    imagePath != null
                                        ? Image.file(
                                          File(imagePath!),
                                          fit: BoxFit.cover,
                                          width: 120,
                                          height: 160,
                                        )
                                        : Icon(Icons.add_a_photo),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Título",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0x23BFBFBF),
                      ),
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Legenda",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10.0),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Color(0x23BFBFBF),
                      ),
                      maxLines: 4,
                    ),
                    SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        "Agendamento",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _dateController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Color(0x23BFBFBF),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SvgPicture.asset(
                                  'assets/icons/calendar.svg',
                                  width: 24,
                                  height: 24,
                                  color: Color(0xFF3B5CFF),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              hintText: "Data",
                              hintStyle: TextStyle(color: Colors.black),
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ),
                              filled: true,
                              fillColor: Color(0x23BFBFBF),
                              prefixIcon: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: SvgPicture.asset(
                                  'assets/icons/clock.svg',
                                  width: 24,
                                  height: 24,
                                  color: Color(0xFF3B5CFF),
                                ),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                              hintText: "Hora",
                              hintStyle: TextStyle(color: Colors.black),
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
            ],
          ),
        ),
        bottomNavigationBar: Container(
          height: 64,
          width: double.infinity,
          color: Color(0xFF3B5CFF),
        ),
      ),
    );
  }
}
