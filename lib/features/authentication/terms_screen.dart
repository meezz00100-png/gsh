import 'package:flutter/material.dart';
import 'package:harari_prosperity_app/routes/app_routes.dart';
import 'package:harari_prosperity_app/shared/widgets/custom_button.dart';

class TermsScreen extends StatefulWidget {
  const TermsScreen({super.key});

  @override
  State<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends State<TermsScreen> {
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
            const Text(
              "Welcome to Harari Regional Prosperity Party\nPolitical Analysis System",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Lorem ipsum dolor sit amet. Et odio officia aut voluptate internos est omnis vitae ut architecto sunt non tenetur fuga ut provident vero. Quo aspernatur facere et consectetur ipsum et facere corrupti est asperiores facere. Est fugiat assumenda aut reprehenderit voluptatem sed.",
            ),
            const SizedBox(height: 20),
            const Text("1. Ea voluptates omnis aut sequi sequi."),
            const Text("2. Est dolore quce in aliquid ducimus et outem repellendus."),
            const Text("3. Aut ipsum Quis qui porto quasi aut minus placcati."),
            const Text("4. Sit consequatur neque do vitae facere."),
            const SizedBox(height: 20),
            const Text(
              "Aut quidem accusantium nam alias autem eum officis placcat et omnis autem id officis perspiciatis qui corrupti officia eum aliquam provident. Eum voluptas error et opio dolorum cum molestiae nobis et odit molestiae quo magnam impedit sed fugiat nihil non nihil vitae.",
            ),
            const SizedBox(height: 20),
            const Text("- Aut fuga sequi eum voluptatibus provident."),
            const Text("- Eos consequuntur voluptas vel amet eaque aut dignissimos velit."),
            const SizedBox(height: 20),
            const Text(
              "Vel exercitationem quam vel eligendi rerum At harum obceccati et nostrum beatae? Ea accusantium dolores qui rerum aliquam est perterentis moltita et ipsum ipsa qui enim autem At corporis sunt. Aut odit quisquam est reprehenderi",
            ),
            const Divider(height: 40),
            const Text(
              "Read the terms and conditions in more detail at www.hrppapp.com.et",
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 20),
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
            Center(
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