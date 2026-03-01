import 'package:uni_tech/models/User.dart';
import 'package:uni_tech/partials/animation_wrapper.dart';
import 'package:uni_tech/partials/glass_container.dart';
import 'package:uni_tech/providers/navigation_provider.dart';
import 'package:uni_tech/styles/texts.dart';
import 'package:uni_tech/utilities/alert.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UsersTable extends ConsumerStatefulWidget {
  const UsersTable({super.key});

  @override
  ConsumerState<UsersTable> createState() => _UsersTableState();
}

class _UsersTableState extends ConsumerState<UsersTable> {
  List<User> users = [];
  Future<void> loadusers() async {
    final u = await getAllUsers();
    setState(() {
      users = u;
    });
  }

  Future<void> deleteuserFromDB(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // prevent closing by tapping outside
      builder: (context) {
        return AlertDialog(
          alignment: Alignment.center, // ⬅ centers the alert on screen
          backgroundColor: Color.fromARGB(255, 22, 22, 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Delete User', style: whiteText),
          content: const Text(
            'Are you sure you want to delete this user?',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: Text('Delete', style: whiteText),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await deleteUser(id);
      setState(() {
        users.removeWhere((user) => user.id == id);
      });
      showCustomAlert(
        context,
        'User deleted successfully!',
        backgroundColor: ksuccess,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    loadusers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedWrapper(
          duration: Duration(milliseconds: 800),
          animations: [AnimationAllowedType.slide],
          slideDirection: SlideDirection.right,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              CustomButton(
                label: "Add New User",
                size: "medium",
                onClick: () {
                  ref
                      .read(navigationProvider.notifier)
                      .setScreen(AppRoutes.usersCreate);
                },
                backgroundColor: Colors.green,
                foregroundColor: kwhite,
              ),
            ],
          ),
        ),
        SizedBox(height: 25),

        AnimatedWrapper(
          duration: Duration(milliseconds: 800),
          animations: [AnimationAllowedType.fade],
          child: GlassContainer(
            height:
                users.isNotEmpty ? null : MediaQuery.of(context).size.height,
            padding: EdgeInsets.symmetric(vertical: 10),
            child:
                users.isNotEmpty
                    ? DataTable(
                      dataRowHeight: 80,
                      dividerThickness: .5,
                      columns: [
                        DataColumn(
                          label: Text("Name", style: tableHeaderStyle),
                        ),
                        DataColumn(label: Text("Age", style: tableHeaderStyle)),
                        DataColumn(
                          label: Text("Phone", style: tableHeaderStyle),
                        ),
                        DataColumn(
                          label: Text("Orders\n Done", style: tableHeaderStyle),
                        ),
                        DataColumn(
                          label: Text("Action", style: tableHeaderStyle),
                        ),
                      ],
                      rows: [
                        ...users.map(
                          (user) => DataRow(
                            cells: [
                              DataCell(
                                onTap: () {
                                  ref
                                      .read(navigationProvider.notifier)
                                      .setScreen(
                                        AppRoutes.usersDetails,
                                        user.id,
                                      );
                                },
                                Row(
                                  children: [
                                    GlassContainer(
                                      width: 60,
                                      height: 60,
                                      padding: EdgeInsets.all(6),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadiusGeometry.circular(15),
                                        child: Image.network(user.image),
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(user.name, style: tableCellStyle),
                                        Text(user.email, style: mutedText),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              DataCell(
                                Text(
                                  user.age.toString(),
                                  style: tableCellStyle,
                                ),
                              ),
                              DataCell(Text(user.phone, style: tableCellStyle)),
                              DataCell(Text("0", style: tableCellStyle)),
                              DataCell(
                                Row(
                                  children: [
                                    CustomButton(
                                      label: "Edit",
                                      size: "small",
                                      onClick: () {
                                        ref
                                            .read(navigationProvider.notifier)
                                            .setScreen(
                                              AppRoutes.usersEdit,
                                              user.id,
                                            );
                                      },
                                      backgroundColor: Colors.blue,
                                      foregroundColor: kwhite,
                                    ),
                                    SizedBox(width: 10),
                                    CustomButton(
                                      label: "Delete",
                                      size: "small",
                                      onClick: () {
                                        deleteuserFromDB(user.id);
                                      },
                                      backgroundColor: Colors.redAccent,
                                      foregroundColor: kwhite,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                    : Center(
                      child: Text("Loading...", style: tableHeaderStyle),
                    ),
          ),
        ),
      ],
    );
  }
}
