import "package:flutter/material.dart";
import "package:lebzcafe/views/account/profile.dart";
import "package:lebzcafe/widgets/common.dart";
import "package:lebzcafe/widgets/common2.dart";
import "package:tu/tu.dart";

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
                      pushTo(const ProfilePage());
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
                      pushNamed("/orders");
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
                      pushNamed("/account/settings");
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
