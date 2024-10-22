import 'package:flutter/material.dart';
import '../../widgets/build_text_field.dart';
import '../../utils/user_repository.dart';
import '../../utils/firebase_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NicknameScreen extends StatefulWidget {
  final Future<void> Function() onNext;

  NicknameScreen({required this.onNext});

  @override
  _NicknameScreenState createState() => _NicknameScreenState();
}

class _NicknameScreenState extends State<NicknameScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  String? _selectedGender;
  String? _selectedOccupation;
  String? _selectedDiscoveryMethod;
  final UserRepository _userRepository = UserRepository(FirebaseService());
  bool _isNicknameChecked = false;
  bool _isNicknameAvailable = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('프로필 설정'),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('닉네임'),
                      NicknameTextFieldWithButton(
                        controller: _nicknameController,
                        onPressed: _checkNicknameDuplicate,
                        validator: _validateNickname,
                        isNicknameAvailable: _isNicknameAvailable,
                      ),
                      SizedBox(height: 32),
                      _buildSectionTitle('성별'),
                      _buildSelectionWidget(
                        options: ['남', '여', '무응답'],
                        selectedOption: _selectedGender,
                        onSelect: (value) =>
                            setState(() => _selectedGender = value),
                      ),
                      SizedBox(height: 24),
                      _buildSectionTitle('직업'),
                      _buildSelectionWidget(
                        options: ['학생', '대졸', '직장인', '무응답'],
                        selectedOption: _selectedOccupation,
                        onSelect: (value) =>
                            setState(() => _selectedOccupation = value),
                      ),
                      SizedBox(height: 24),
                      _buildSectionTitle('서비스 인지 경로'),
                      _buildSelectionWidget(
                        options: [
                          'Instagram 광고',
                          '인터넷 검색',
                          '지인 추천',
                          '앱스토어',
                          '기타',
                          '무응답'
                        ],
                        selectedOption: _selectedDiscoveryMethod,
                        onSelect: (value) =>
                            setState(() => _selectedDiscoveryMethod = value),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              child: Text('가입 완료', style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: _submitForm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }

  Widget _buildSelectionWidget({
    required List<String> options,
    required String? selectedOption,
    required Function(String) onSelect,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        return ChoiceChip(
          label: Text(option),
          selected: selectedOption == option,
          onSelected: (selected) {
            if (selected) onSelect(option);
          },
          selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
          backgroundColor: Colors.grey[200],
          labelStyle: TextStyle(
            color: selectedOption == option
                ? Theme.of(context).primaryColor
                : Colors.black87,
          ),
        );
      }).toList(),
    );
  }

  String? _validateNickname(String? value) {
    if (value!.isEmpty) {
      return '닉네임을 입력해주세요';
    }
    if (value.length < 3 || value.length > 12) {
      return '닉네임은 3자에서 12자 사이여야 합니다';
    }
    if (!RegExp(r'^[a-zA-Z0-9가-힣]+$').hasMatch(value)) {
      return '닉네임은 한글, 영어, 숫자만 사용 가능합니다';
    }
    if (!_isNicknameChecked) {
      return '중복 확인을 해주세요';
    }
    if (!_isNicknameAvailable) {
      return '이미 사용 중인 닉네임입니다';
    }
    return null;
  }

  Future<void> _checkNicknameDuplicate() async {
    setState(() {
      _isNicknameChecked = false;
      _isNicknameAvailable = false;
    });

    bool isAvailable =
        await _userRepository.isNicknameAvailable(_nicknameController.text);

    setState(() {
      _isNicknameAvailable = isAvailable;
      if (_isNicknameAvailable) {
        _isNicknameChecked = true;
      }
    });

    // 폼의 상태를 갱신하여 validator를 다시 실행합니다.
    _formKey.currentState?.validate();
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      if (!_isNicknameChecked || !_isNicknameAvailable) {
        // 닉네임 중복 확인이 되지 않았거나 사용 불가능한 경우 제출하지 않습니다.
        return;
      }

      try {
        User? currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          throw Exception('현재 로그인된 사용자가 없습니다.');
        }

        Map<String, dynamic> userInfo = {
          'nickname': _nicknameController.text,
          'gender': _selectedGender ?? '무응답',
          'occupation': _selectedOccupation ?? '무응답',
          'discoveryMethod': _selectedDiscoveryMethod ?? '무응답',
        };

        await _userRepository.updateUserInfo(currentUser.uid, userInfo);

        // 성공적으로 저장되면 다음 단계로 진행
        await widget.onNext();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('사용자 정보 저장 중 오류가 발생했습니다: $e')),
        );
      }
    }
  }
}
