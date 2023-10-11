import 'package:flutter/material.dart';
import 'package:frust/utils/constants.dart';
import 'package:frust/utils/functions.dart';
import 'package:frust/utils/styles.dart';
import 'package:frust/views/account/profile.dart';
import 'package:frust/views/order/index.dart';
import 'package:frust/widgets/common.dart';
import 'package:frust/widgets/common2.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: childAppbar(title: "Account"),
      body: Container(
        padding: defaultPadding2,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            mY(5),
            SingleChildScrollView(
              child: Column(children: [
                TuCard(
                    my: 0,
                    radius: 0,
                    borderSize: 0,
                    onTap: () {
                      pushTo(context, const ProfilePage());
                    },
                    child: const TuListTile(
                        title: Text(
                          "Profile",
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.black54,
                        ))),
                TuCard(
                    my: 0,
                    radius: 0,
                    borderSize: 0,
                    onTap: () {
                      Navigator.pushNamed(context, '/orders');
                    },
                    child: const TuListTile(
                        title: Text(
                          "Orders",
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.black54,
                        ))),
                TuCard(
                    my: 0,
                    radius: 0,
                    borderSize: 0,
                    onTap: () {
                      clog("To settings");
                      pushNamed(context, '/account/settings');
                    },
                    child: const TuListTile(
                        title: Text(
                          "Settings",
                        ),
                        trailing: Icon(
                          Icons.chevron_right,
                          color: Colors.black54,
                        ))),
              ]),
            )
          ],
        ),
      ),
    );
  }
}
