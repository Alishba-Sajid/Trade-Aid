import 'package:flutter/material.dart';

class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _loading = false);

    if (!mounted) return;
    Navigator.popUntil(context, (r) => r.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create New Password"),
        backgroundColor: const Color.fromARGB(255, 17, 158, 144),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const SizedBox(height: 40),

              const Icon(Icons.lock, size: 100, color: Colors.amber),

              const SizedBox(height: 30),

              TextFormField(
                controller: _pass1,
                obscureText: true,
                validator: (v) =>
                    v == null || v.length < 4 ? "Min 4 chars" : null,
                decoration: const InputDecoration(labelText: "New Password"),
              ),

              const SizedBox(height: 20),

              TextFormField(
                controller: _pass2,
                obscureText: true,
                validator: (v) =>
                    v != _pass1.text ? "Passwords do not match" : null,
                decoration: const InputDecoration(
                  labelText: "Confirm Password",
                ),
              ),

              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _loading ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 17, 158, 144),
                  ),
                  child: _loading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Save",
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
