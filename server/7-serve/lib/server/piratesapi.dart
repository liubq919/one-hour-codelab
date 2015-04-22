// Copyright (c) 2015, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

library pirate.server;

import 'package:rpc/api.dart';

import '../common/messages.dart';
import '../common/utils.dart';

// This class defines the interface that the server provides.
@ApiClass(version: 'v1')
class PiratesApi {
  final Map<String, Pirate> _pirateCrew = {};
  final PirateShanghaier _shanghaier = new PirateShanghaier();

  @ApiMethod(method: 'POST', path: 'pirate')
  Pirate hirePirate(Pirate newPirate) {
    // Make sure this is a real pirate...
    if (!truePirate(newPirate)) {
      throw new BadRequestError(
          '$newPirate cannot be a pirate. \'Tis not a pirate name!');
    }
    var pirateName = newPirate.toString();
    if (_pirateCrew.containsKey(pirateName)) {
      throw new BadRequestError(
          '$newPirate is already part of your crew!');
    }

    // Add pirate to store.
    _pirateCrew[pirateName] = newPirate;
    return newPirate;
  }

  @ApiMethod(method: 'DELETE', path: 'pirate/{name}/the/{appellation}')
  Pirate firePirate(String name, String appellation) {
    var pirate = new Pirate()
      ..name = Uri.decodeComponent(name)
      ..appellation = Uri.decodeComponent(appellation);
    var pirateName = pirate.toString();
    if (!_pirateCrew.containsKey(pirateName)) {
      throw new NotFoundError(
          'Could not find pirate \'$pirate\'!' +
          'Maybe they\'ve abandoned ship!');
    }
    return _pirateCrew.remove(pirateName);
  }

  @ApiMethod(method: 'GET', path: 'pirates')
  List<Pirate> listPirates() {
    return _pirateCrew.values.toList();
  }

  @ApiMethod(path: 'shanghai') // Default HTTP method is GET.
  Pirate shanghaiAPirate() {
    var pirate = _shanghaier.shanghaiAPirate();
    if (pirate == null) {
      throw new InternalServerError('Ran out of pirates!');
    }
    return pirate;
  }
}
