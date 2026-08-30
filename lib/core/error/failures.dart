abstract class Failure {
  final String message;
  const Failure(this.message);
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

// Firebase Auth error codes → رسائل مفهومة
class AuthFailureHandler {
  static AuthFailure fromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return const AuthFailure('البريد الإلكتروني غير مسجل');
      case 'wrong-password':
        return const AuthFailure('كلمة المرور غير صحيحة');
      case 'email-already-in-use':
        return const AuthFailure('البريد الإلكتروني مستخدم بالفعل');
      case 'weak-password':
        return const AuthFailure('كلمة المرور ضعيفة جداً');
      case 'invalid-email':
        return const AuthFailure('البريد الإلكتروني غير صحيح');
      case 'too-many-requests':
        return const AuthFailure('تم تجاوز عدد المحاولات، حاول لاحقاً');
      case 'network-request-failed':
        return const AuthFailure('تحقق من اتصالك بالإنترنت');
      default:
        return const AuthFailure('حدث خطأ، حاول مرة أخرى');
    }
  }
}