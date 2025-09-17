import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';

class TermsViewScreen extends StatefulWidget {
  const TermsViewScreen({super.key});

  @override
  State<TermsViewScreen> createState() => _TermsViewScreenState();
}

class _TermsViewScreenState extends State<TermsViewScreen> {
  bool _isAccepted = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Terms And Conditions")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome to Harari Regional Prosperity Party\nPolitical Analysis System",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Lorem ipsum dolor sit amet. Et odio officia aut voluptate internos est omnis vitae ut architecto sunt non tenetur fuga ut provident vero. Quo aspernatur facere et consectetur ipsum et facere corrupti est asperiores facere. Est fugiat assumenda aut reprehenderit voluptatem sed.",
            ),
            SizedBox(height: 20),
            Text("1. Ea voluptates omnis aut sequi sequi."),
            Text("2. Est dolore quce in aliquid ducimus et outem repellendus."),
            Text("3. Aut ipsum Quis qui porto quasi aut minus placcati."),
            Text("4. Sit consequatur neque do vitae facere."),
            SizedBox(height: 20),
            Text(
              "Aut quidem accusantium nam alias autem eum officis placcat et omnis autem id officis perspiciatis qui corrupti officia eum aliquam provident. Eum voluptas error et opio dolorum cum molestiae nobis et odit molestiae quo magnam impedit sed fugiat nihil non nihil vitae.",
            ),
            SizedBox(height: 20),
            Text("- Aut fuga sequi eum voluptatibus provident."),
            Text("- Eos consequuntur voluptas vel amet eaque aut dignissimos velit."),
            SizedBox(height: 20),
            Text(
              "Vel exercitationem quam vel eligendi rerum At harum obceccati et nostrum beatae? Ea accusantium dolores qui rerum aliquam est perterentis moltita et ipsum ipsa qui enim autem At corporis sunt. Aut odit quisquam est reprehenderi",
            ),
            Divider(height: 40),
            Text(
              "Read the terms and conditions in more detail at www.hrppapp.com.et",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: _isAccepted,
                  onChanged: (value) {
                    setState(() {
                      _isAccepted = value ?? false;
                    });
                  },
                ),
                Expanded(
                  child: Text("I accept all the terms and conditions"),
                ),
              ],
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: CustomButton(
                text: "Accept & Continue",
                onPressed: _isAccepted
                    ? () => Navigator.pushNamed(context, AppRoutes.login)
                    : null,
                filled: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
