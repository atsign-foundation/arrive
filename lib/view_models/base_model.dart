import 'package:flutter/material.dart';

class BaseModel with ChangeNotifier {
  Map<String, Status> status = {'main': Status.Idle};
  Map<String, String?> error = {};
  // ignore: always_declare_return_types
  setStatus(String function, Status _status) {
    status[function] = _status;
    notifyListeners();
  }

  // ignore: always_declare_return_types
  setError(String function, String _error, [Status? _status]) {
    if (_error != null) {
      error[function] = _error;
      status[function] = Status.Error;
    } else {
      error[function] = null;
      status[function] = _status ?? Status.Idle;
    }
    notifyListeners();
  }

  // ignore: always_declare_return_types
  reset(String function) {
    error.remove(function);
    status.remove(function);
  }
}

enum Status { Loading, Done, Error, Idle }
