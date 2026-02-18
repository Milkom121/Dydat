import 'package:flutter/material.dart';
import '../../../core/sizer_extensions.dart';

import '../../../core/app_export.dart';
import '../../../widgets/custom_icon_widget.dart';

/// Form widget for user registration with validation
class RegistrationFormWidget extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController nomeController;
  final bool isPasswordVisible;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onPasswordVisibilityToggle;
  final String? Function(String?) validateEmail;
  final String? Function(String?) validatePassword;
  final String? Function(String?) validateNome;
  final VoidCallback onSubmit;

  const RegistrationFormWidget({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.nomeController,
    required this.isPasswordVisible,
    required this.isLoading,
    required this.errorMessage,
    required this.onPasswordVisibilityToggle,
    required this.validateEmail,
    required this.validatePassword,
    required this.validateNome,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Nome field
          TextFormField(
            controller: nomeController,
            enabled: !isLoading,
            keyboardType: TextInputType.name,
            textInputAction: TextInputAction.next,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Nome',
              hintText: 'Inserisci il tuo nome',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'person',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
            ),
            validator: validateNome,
          ),

          SizedBox(height: 2.h),

          // Email field
          TextFormField(
            controller: emailController,
            enabled: !isLoading,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Email',
              hintText: 'esempio@email.com',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'email',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
            ),
            validator: validateEmail,
          ),

          SizedBox(height: 2.h),

          // Password field
          TextFormField(
            controller: passwordController,
            enabled: !isLoading,
            obscureText: !isPasswordVisible,
            textInputAction: TextInputAction.done,
            style: theme.textTheme.bodyLarge,
            decoration: InputDecoration(
              labelText: 'Password',
              hintText: 'Almeno 8 caratteri',
              prefixIcon: Padding(
                padding: EdgeInsets.all(3.w),
                child: CustomIconWidget(
                  iconName: 'lock',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
              ),
              suffixIcon: IconButton(
                icon: CustomIconWidget(
                  iconName: isPasswordVisible ? 'visibility' : 'visibility_off',
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 5.w,
                ),
                onPressed: onPasswordVisibilityToggle,
              ),
            ),
            validator: validatePassword,
            onFieldSubmitted: (_) => onSubmit(),
          ),

          SizedBox(height: 1.h),

          // Password requirements hint
          Text(
            'La password deve contenere almeno 8 caratteri, una maiuscola e un numero',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          // Error message
          if (errorMessage != null) ...[
            SizedBox(height: 2.h),
            Container(
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: theme.colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: theme.colorScheme.error.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'error_outline',
                    color: theme.colorScheme.error,
                    size: 5.w,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          SizedBox(height: 4.h),

          // Submit button
          SizedBox(
            height: 6.h,
            child: ElevatedButton(
              onPressed: isLoading ? null : onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
                disabledBackgroundColor: theme.colorScheme.onSurfaceVariant
                    .withValues(alpha: 0.3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 5.w,
                      height: 5.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : Text(
                      'Crea account',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
