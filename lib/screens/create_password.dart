import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:passwordy/screens/add_secret_screen.dart';
import 'package:passwordy/service/db/database.dart';
import 'package:passwordy/service/db/db_vault.dart';
import 'package:passwordy/service/preferences.dart';
import 'dart:math';

import 'package:passwordy/widgets/add_options_state.dart';
import 'package:passwordy/widgets/new_item_chooser.dart';

class CreatePasswordScreen extends AddOptionsWidget {
  final bool useSaveButton;
  CreatePasswordScreen({super.key, this.useSaveButton = false});

  @override
  _CreatePasswordScreenState createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen>
    with KeyedAddOptionsState<CreatePasswordScreen> {
  final prefs = Preferences.instance.prefs;
  String generatedPassword = '';
  int passwordLength = 12;
  bool useUppercase = true;
  bool useLowercase = true;
  bool useDigits = true;
  bool useSpecialChars = true;
  bool omitAmbiguous = false;

  final String uppercaseChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  final String lowercaseChars = 'abcdefghijklmnopqrstuvwxyz';
  final String digitChars = '0123456789';
  final String specialChars = '!@#\$%^&*()_+-=[]{};:,.<>?';
  final String ambiguousChars = 'l1Io0O';

  @override
  void initState() {
    super.initState();
    passwordLength = prefs.getInt('passwordLength') ?? passwordLength;
    useUppercase = prefs.getBool('useUppercase') ?? useUppercase;
    useLowercase = prefs.getBool('useLowercase') ?? useLowercase;
    useDigits = prefs.getBool('useDigits') ?? useDigits;
    useSpecialChars = prefs.getBool('useSpecialChars') ?? useSpecialChars;
    omitAmbiguous = prefs.getBool('omitAmbiguous') ?? omitAmbiguous;

    generatePassword();
  }

  Future<void> savePrefs() async {
    await prefs.setInt('passwordLength', passwordLength);
    await prefs.setBool('useUppercase', useUppercase);
    await prefs.setBool('useLowercase', useLowercase);
    await prefs.setBool('useDigits', useDigits);
    await prefs.setBool('useSpecialChars', useSpecialChars);
    await prefs.setBool('omitAmbiguous', omitAmbiguous);
  }

  void generatePassword() {
    String chars = '';
    String letters = '';
    String digits = '';
    String specialChars = '';
    if (useUppercase) letters += uppercaseChars;
    if (useLowercase) letters += lowercaseChars;
    if (useDigits) digits += digitChars;
    if (useSpecialChars) specialChars += this.specialChars;
    if (omitAmbiguous) {
      letters = letters.replaceAll(RegExp('[$ambiguousChars]'), '');
      digits = digits.replaceAll(RegExp('[$ambiguousChars]'), '');
    }

    if (letters + digits + specialChars == '') {
      setState(() {
        generatedPassword = 'Select at least one character type';
      });
      return;
    }

    final random = Random.secure();
    final parts = <String>[];
    int leftChars = passwordLength;
    if (specialChars.isNotEmpty) {
      final specialCharsCount = random.nextInt(passwordLength ~/ 8)  + 1;
      parts.addAll(List.generate(
          specialCharsCount, (_) => specialChars[random.nextInt(
          specialChars.length)]));
      leftChars -= specialCharsCount;
    }
    if (digits.isNotEmpty) {
      final digitsCount = random.nextInt(passwordLength ~/ 4) + 1;
      parts.addAll(List.generate(
          digitsCount, (_) => digits[random.nextInt(digits.length)]));
      leftChars -= digitsCount;
    }

    if (letters.isNotEmpty) {
      final lettersCount = leftChars;
      parts.addAll(List.generate(
          lettersCount, (_) => letters[random.nextInt(letters.length)]));
      leftChars -= lettersCount;
    }
    chars = letters + digits + specialChars;

    if (leftChars > 0) {
      parts.addAll(
          List.generate(leftChars, (_) => chars[random.nextInt(chars.length)]));
    }
    final passwordChars = List.generate(passwordLength, (_) {
      final idx = random.nextInt(parts.length);
      final char = parts[idx];
      parts.removeAt(idx);
      return char;
    });
    setState(() {
      generatedPassword = passwordChars.join();
    });
  }

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: generatedPassword)).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password copied to clipboard')),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Password'),
        actions: widget.useSaveButton ? [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => Navigator.pop(context, {'password': generatedPassword}),
          ),
        ] : [],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Generated Password:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      generatedPassword,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: generatePassword,
                    tooltip: 'Regenerate Password',
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: copyToClipboard,
                    tooltip: 'Copy to Clipboard',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Password Length: $passwordLength',
              style: const TextStyle(fontSize: 16),
            ),
            Slider(
              value: passwordLength.toDouble(),
              min: 8,
              max: 32,
              divisions: 24,
              onChanged: (value) {
                setState(() {
                  passwordLength = value.round();
                  savePrefs();
                });
                generatePassword();
              },
            ),
            SwitchListTile(
              title: const Text('Uppercase (A-Z)'),
              value: useUppercase,
              onChanged: (value) {
                setState(() {
                  useUppercase = value;
                  savePrefs();
                });
                generatePassword();
              },
            ),
            SwitchListTile(
              title: const Text('Lowercase (a-z)'),
              value: useLowercase,
              onChanged: (value) {
                setState(() {
                  useLowercase = value;
                  savePrefs();
                });
                generatePassword();
              },
            ),
            SwitchListTile(
              title: const Text('Numbers (0-9)'),
              value: useDigits,
              onChanged: (value) {
                setState(() {
                  useDigits = value;
                  savePrefs();
                });
                generatePassword();
              },
            ),
            SwitchListTile(
              title: const Text('Special Characters (!@#\$%^&*...)'),
              value: useSpecialChars,
              onChanged: (value) {
                setState(() {
                  useSpecialChars = value;
                  savePrefs();
                });
                generatePassword();
              },
            ),
            SwitchListTile(
              title: const Text('Avoid Ambiguous Characters'),
              subtitle: const Text('(l, 1, I, o, 0, O)'),
              value: omitAmbiguous,
              onChanged: (value) {
                setState(() {
                  omitAmbiguous = value;
                  savePrefs();
                });
                generatePassword();
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  void showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return NewItemChooser(
          vault: Vault.vault,
          onItemSelected: (Template item) {
            // Handle the selected item
            Navigator.push(context, MaterialPageRoute(builder: (_) => AddSecretScreen(template: item)));
          },
        );
      },
    );
  }
}