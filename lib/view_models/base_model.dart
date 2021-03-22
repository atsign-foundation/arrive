import 'package:flutter/material.dart';

class BaseModel with ChangeNotifier {
  Map<String, Status> status = {'main': Status.Idle};
  Map<String, String> error = {};
  setStatus(String function, Status _status) {
    this.status[function] = _status;
    notifyListeners();
  }

  setError(String function, String _error, [Status _status]) {
    if (_error != null) {
      error[function] = _error;
      status[function] = Status.Error;
    } else {
      this.error[function] = null;
      this.status[function] = _status ?? Status.Idle;
    }
    notifyListeners();
  }

  reset(String function) {
    this.error?.remove(function);
    this.status?.remove(function);
  }
}

enum Status { Loading, Done, Error, Idle }
