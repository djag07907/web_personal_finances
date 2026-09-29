import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:internationalization/internationalization.dart';
import 'package:web_personal_finances/commons/cards/custom_card_body.dart';
import 'package:web_personal_finances/commons/loader/loader.dart';
import 'package:web_personal_finances/commons/snackBar/custom_snackbar.dart';
import 'package:web_personal_finances/profile/bloc/profile_bloc.dart';
import 'package:web_personal_finances/profile/bloc/profile_event.dart';
import 'package:web_personal_finances/profile/bloc/profile_state.dart';
import 'package:web_personal_finances/profile/widget/profile_details_view.dart';
import 'package:web_personal_finances/profile/widget/profile_edit_form.dart';
import 'package:web_personal_finances/profile/widget/profile_header.dart';
import 'package:web_personal_finances/user/model/user_model.dart';

class ProfileBody extends StatefulWidget {
  const ProfileBody({super.key});

  @override
  State<ProfileBody> createState() => _ProfileBodyState();
}

class _ProfileBodyState extends State<ProfileBody> {
  bool _isEditing = false;

  @override
  Widget build(final BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocConsumer<ProfileBloc, ProfileState>(
      listener: (final BuildContext context, final ProfileState state) {
        if (state is ProfileSuccess) {
          setState(() {
            _isEditing = false;
          });
          showSnackbar(context, state.message);
        } else if (state is ProfileError) {
          showSnackbar(context, state.message);
        }
      },
      builder: (final BuildContext context, final ProfileState state) {
        if (state is ProfileInitial || state is ProfileLoading) {
          return const Loader();
        }

        UserModel? user;
        bool isSaving = false;

        if (state is ProfileLoaded) {
          user = state.user;
        } else if (state is ProfileSaving) {
          user = state.user;
          isSaving = true;
        } else if (state is ProfileSuccess) {
          user = state.user;
        }

        if (user == null) {
          return const Loader();
        }

        return Stack(
          children: <Widget>[
            CustomCardBody(
              isMain: false,
              isMenu: true,
              title: context.translate('profile'),
              description:
                  'Manage your personal account details and preferences',
              buttonText: _isEditing ? 'Cancel Edit' : 'Edit Profile',
              buttonIsPrimary: !_isEditing,
              onButtonPressed: () {
                setState(() {
                  _isEditing = !_isEditing;
                });
              },
              body: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      ProfileHeader(user: user, isDark: isDark),
                      const SizedBox(height: 24),
                      if (_isEditing)
                        ProfileEditForm(
                          user: user,
                          isDark: isDark,
                          onSave: (final UserModel updatedUser) {
                            context.read<ProfileBloc>().add(
                              ProfileUpdateRequested(user: updatedUser),
                            );
                          },
                          onCancel: () {
                            setState(() {
                              _isEditing = false;
                            });
                          },
                        )
                      else
                        ProfileDetailsView(user: user, isDark: isDark),
                    ],
                  ),
                ),
              ),
            ),
            if (isSaving) const Loader(),
          ],
        );
      },
    );
  }
}
