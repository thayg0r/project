import 'package:flutter/material.dart';
import 'package:project/scheduling/scheduling_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:project/data/local/post_storage.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  late DateTime _selectedDay;
  late DateTime _focusedDay;
  late DateTime _lastDay;

  List<Map<String, String>> _posts = [];
  Map<String, int> postDay = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _focusedDay = _selectedDay;

    _lastDay = DateTime.utc(2035, 12, 31);

    if (_focusedDay.isAfter(_lastDay)) {
      _focusedDay = _lastDay;
    }

    _loadPosts();
  }

  _loadPosts() async {
    final storedData = await PostStorage.loadPostagens();
    setState(() {
      _posts = storedData;
      _postsCounter();
    });
  }

  _postsCounter() {
    postDay.clear();
    for (var post in _posts) {
      String date = post['date']?.split('T')[0] ?? '';
      postDay[date] = (postDay[date] ?? 0) + 1;
    }
  }

  void _deletePost(int index) async {
    setState(() {
      _posts.removeAt(index);
    });

    await PostStorage.savePosts(_posts);
  }

  Future<void> _showConfirmationDialog(
    int index,
    String titulo,
    String data,
    String hora,
  ) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirmação"),
          content: Text(
            'Tem certeza que deseja excluir a postagem "$titulo" de $data às $hora?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _loadPosts();
              },
              child: Text("Cancelar"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deletePost(index);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Postagem excluída com sucesso!')),
                );
                _loadPosts();
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
            "Postagens Agendadas",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TableCalendar(
                  locale: 'pt_BR',
                  focusedDay: _focusedDay,
                  firstDay: DateTime.utc(2010, 01, 01),
                  lastDay: DateTime.utc(2035, 12, 31),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  daysOfWeekStyle: DaysOfWeekStyle(
                    dowTextFormatter: (date, locale) {
                      String short = DateFormat.E(locale).format(date);
                      short = short.replaceAll('.', '').substring(0, 3);
                      return short[0].toUpperCase() + short.substring(1);
                    },
                    weekdayStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF636363),
                    ),
                    weekendStyle: TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF636363),
                    ),
                  ),
                  selectedDayPredicate: (day) {
                    return isSameDay(_selectedDay, day);
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay =
                          focusedDay.isAfter(_lastDay) ? _lastDay : focusedDay;
                    });
                  },
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0x80F58529),
                          Color(0x80DD2A7B),
                          Color(0x808134AF),
                          Color(0x80515BD4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Color(0xFFF58529),
                          Color(0xFFDD2A7B),
                          Color(0xFF8134AF),
                          Color(0xFF515BD4),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    formatButtonVisible: false,
                    titleTextFormatter: (date, locale) {
                      String month = DateFormat.MMMM(locale).format(date);
                      String year = DateFormat.y(locale).format(date);
                      return '${month[0].toUpperCase()}${month.substring(1)} $year';
                    },
                  ),
                  availableCalendarFormats: {CalendarFormat.month: 'Month'},
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      String dateStr = date.toIso8601String().split('T')[0];
                      int postCount = postDay[dateStr] ?? 0;
                      if (postCount > 0) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            postCount,
                            (index) => Container(
                              margin: EdgeInsets.only(left: index == 0 ? 0 : 2),
                              height: 6,
                              width: 6,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFF58529),
                                    Color(0xFFDD2A7B),
                                    Color(0xFF8134AF),
                                    Color(0xFF515BD4),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        );
                      }
                      return SizedBox.shrink();
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Postagens agendadas',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              Builder(
                builder: (context) {
                  final postsDoDia =
                      _posts.where((post) {
                        if (post['date'] == null) return false;
                        final postDate = DateTime.parse(post['date']!);
                        return postDate.year == _selectedDay.year &&
                            postDate.month == _selectedDay.month &&
                            postDate.day == _selectedDay.day;
                      }).toList();

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: postsDoDia.length,
                    itemBuilder: (context, index) {
                      final post = postsDoDia[index];
                      DateTime postDate = DateTime.parse(post['date']!);
                      String formattedDate = DateFormat(
                        'dd/MM/yyyy',
                      ).format(postDate);
                      String formattedTime = DateFormat(
                        'HH:mm',
                      ).format(postDate);
                      return Dismissible(
                        key: Key(post['title'] ?? 'Sem Título'),
                        direction: DismissDirection.horizontal,
                        confirmDismiss: (direction) async {
                          if (direction == DismissDirection.endToStart) {
                            String titulo = post['title'] ?? 'Sem Título';
                            String data = formattedDate;
                            String hora = formattedTime;
                            bool? confirm = await showDialog<bool>(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirmação"),
                                  content: Text(
                                    'Tem certeza que deseja excluir a postagem "$titulo" de $data às $hora?',
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(false);
                                        _loadPosts();
                                      },
                                      child: Text("Cancelar"),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop(true);
                                      },
                                      child: Text("Confirmar"),
                                    ),
                                  ],
                                );
                              },
                            );
                            return confirm == true;
                          } else if (direction == DismissDirection.startToEnd) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => SchedulingScreen(post: post),
                              ),
                            ).then((_) {
                              _loadPosts();
                            });
                            return false;
                          }
                          return false;
                        },
                        onDismissed: (direction) {
                          if (direction == DismissDirection.endToStart) {
                            _deletePost(_posts.indexOf(post));
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Postagem excluída com sucesso!'),
                              ),
                            );
                            _loadPosts();
                          }
                        },
                        background: Container(
                          color: Colors.green,
                          alignment: Alignment.centerLeft,
                          padding: EdgeInsets.only(left: 20),
                          child: SvgPicture.asset(
                            'assets/icons/edit.svg',
                            width: 30,
                            height: 30,
                            color: Colors.white,
                          ),
                        ),
                        secondaryBackground: Container(
                          color: Colors.red,
                          alignment: Alignment.centerRight,
                          padding: EdgeInsets.only(right: 20),
                          child: SvgPicture.asset(
                            'assets/icons/trash.svg',
                            width: 30,
                            height: 30,
                            color: Colors.white,
                          ),
                        ),
                        child: Card(
                          margin: EdgeInsets.all(8),
                          color: Colors.transparent,
                          elevation: 0,
                          child: ListTile(
                            contentPadding: EdgeInsets.only(left: 10),
                            title: Text(
                              post['title'] ?? 'Sem Título',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(post['description'] ?? 'Sem Descrição'),
                                SizedBox(height: 2),
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(0xFFF58529),
                                        Color(0xFFDD2A7B),
                                        Color(0xFF8134AF),
                                        Color(0xFF515BD4),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    borderRadius: BorderRadius.circular(44.0),
                                  ),
                                  padding: EdgeInsets.symmetric(horizontal: 5),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SvgPicture.asset(
                                        'assets/icons/clock.svg',
                                        width: 13,
                                        height: 13,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        formattedDate,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        formattedTime,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            leading:
                                post['image'] != null
                                    ? ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: Image.asset(
                                        post['image']!,
                                        width: 60,
                                        height: 62,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                    : Icon(Icons.image),
                            trailing: Padding(
                              padding: const EdgeInsets.only(bottom: 25),
                              child: IconButton(
                                icon: Icon(
                                  Icons.more_vert,
                                  size: 18,
                                  color: Colors.grey[700],
                                ),
                                onPressed: () {
                                  showModalBottomSheet(
                                    context: context,
                                    builder: (context) {
                                      return SafeArea(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            ListTile(
                                              leading: SvgPicture.asset(
                                                'assets/icons/edit.svg',
                                                width: 24,
                                                height: 24,
                                                color: Color(0xFF3B5CFF),
                                              ),
                                              title: Text('Editar'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder:
                                                        (context) =>
                                                            SchedulingScreen(
                                                              post: post,
                                                            ),
                                                  ),
                                                ).then((_) {
                                                  _loadPosts();
                                                });
                                              },
                                            ),
                                            ListTile(
                                              leading: SvgPicture.asset(
                                                'assets/icons/trash.svg',
                                                width: 24,
                                                height: 24,
                                                color: Colors.red,
                                              ),
                                              title: Text('Excluir'),
                                              onTap: () {
                                                Navigator.pop(context);
                                                String titulo =
                                                    post['title'] ??
                                                    'Sem Título';
                                                String data = formattedDate;
                                                String hora = formattedTime;
                                                _showConfirmationDialog(
                                                  _posts.indexOf(post),
                                                  titulo,
                                                  data,
                                                  hora,
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
              SizedBox(height: 80),
            ],
          ),
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 82, right: 8),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  Color(0xFFF58529),
                  Color(0xFFDD2A7B),
                  Color(0xFF8134AF),
                  Color(0xFF515BD4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SchedulingScreen()),
                ).then((_) {
                  _loadPosts();
                });
              },
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(44),
              ),
              child: Icon(Icons.add, color: Colors.white),
            ),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
        bottomNavigationBar: Container(
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFFF58529),
                Color(0xFFDD2A7B),
                Color(0xFF8134AF),
                Color(0xFF515BD4),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
    );
  }
}
