import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:formz/formz.dart';
import 'package:world_travel/features/profile/models/user_name.dart';

typedef UseNameForm<T extends FormzInput<String, E>, E> = ({
  T input,
  TextEditingController textEditingController,
  void Function(String name) pure,
  void Function(String name) dirty,
});

UseNameForm<T, E> useNameForm<T extends FormzInput<String, E>, E>(
  String? name,
  T Function({String value}) makePure,
  T Function({String value}) makeDirty,
) {
  final input = useState(makePure(value: name ?? ''));
  final textEditingController = useTextEditingController(text: name ?? '');

  final pure = useCallback(
    (String name) {
      input.value = makePure(value: name);
    },
    [input],
  );

  final dirty = useCallback(
    (String name) {
      input.value = makeDirty(value: name);
    },
    [input],
  );

  return (
    input: input.value,
    textEditingController: textEditingController,
    pure: pure,
    dirty: dirty,
  );
}

typedef UseSingleNameForm = ({
  UseNameForm<NameInput, NameInputError> nameForm,
  String Function() name,
});

UseSingleNameForm useSingleNameForm({
  String? name,
}) {
  final nameForm = useNameForm<NameInput, NameInputError>(
    name,
    NameInput.pure,
    NameInput.dirty,
  );

  return (
    nameForm: nameForm,
    name: () => nameForm.input.value,
  );
}

typedef UseUserNameForm = ({
  UseNameForm<NameInput, NameInputError> lastNameForm,
  UseNameForm<NameInput, NameInputError> firstNameForm,
  UseNameForm<KanaNameInput, KanaNameInputError> kanaLastNameForm,
  UseNameForm<KanaNameInput, KanaNameInputError> kanaFirstNameForm,
  UserName Function() userName,
});

UseUserNameForm useUserNameForm({
  String? lastName,
  String? firstName,
  String? kanaLastName,
  String? kanaFirstName,
}) {
  final lastNameForm = useNameForm<NameInput, NameInputError>(
    lastName,
    NameInput.pure,
    NameInput.dirty,
  );
  final firstNameForm = useNameForm<NameInput, NameInputError>(
    firstName,
    NameInput.pure,
    NameInput.dirty,
  );
  final kanaLastNameForm = useNameForm<KanaNameInput, KanaNameInputError>(
    kanaLastName,
    KanaNameInput.pure,
    KanaNameInput.dirty,
  );
  final kanaFirstNameForm = useNameForm<KanaNameInput, KanaNameInputError>(
    kanaFirstName,
    KanaNameInput.pure,
    KanaNameInput.dirty,
  );

  return (
    lastNameForm: lastNameForm,
    firstNameForm: firstNameForm,
    kanaLastNameForm: kanaLastNameForm,
    kanaFirstNameForm: kanaFirstNameForm,
    userName: () => UserName(
          lastName: lastNameForm.input.value,
          firstName: firstNameForm.input.value,
          kanaLastName: kanaLastNameForm.input.value,
          kanaFirstName: kanaFirstNameForm.input.value,
        ),
  );
}

enum NameInputError { empty }

class NameInput extends FormzInput<String, NameInputError> {
  const NameInput.pure({String value = ''}) : super.pure(value);
  const NameInput.dirty({String value = ''}) : super.dirty(value);

  @override
  NameInputError? validator(String value) {
    if (value.isEmpty) {
      return NameInputError.empty;
    }

    return null;
  }
}

enum KanaNameInputError { empty, notKana }

class KanaNameInput extends FormzInput<String, KanaNameInputError> {
  const KanaNameInput.pure({String value = ''}) : super.pure(value);
  const KanaNameInput.dirty({String value = ''}) : super.dirty(value);

  @override
  KanaNameInputError? validator(String value) {
    if (value.isEmpty) {
      return KanaNameInputError.empty;
    }

    if (!RegExp(r'^[ァ-ヶー]*$').hasMatch(value)) {
      return KanaNameInputError.notKana;
    }

    return null;
  }
}
