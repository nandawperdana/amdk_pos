// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $ProductsTable extends Products with TableInfo<$ProductsTable, Product> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _brandMeta = const VerificationMeta('brand');
  @override
  late final GeneratedColumn<String> brand = GeneratedColumn<String>(
      'brand', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('other'));
  static const VerificationMeta _baseUnitMeta =
      const VerificationMeta('baseUnit');
  @override
  late final GeneratedColumn<String> baseUnit = GeneratedColumn<String>(
      'base_unit', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('pcs'));
  static const VerificationMeta _packUnitMeta =
      const VerificationMeta('packUnit');
  @override
  late final GeneratedColumn<String> packUnit = GeneratedColumn<String>(
      'pack_unit', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _packSizeMeta =
      const VerificationMeta('packSize');
  @override
  late final GeneratedColumn<int> packSize = GeneratedColumn<int>(
      'pack_size', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _buyPriceMeta =
      const VerificationMeta('buyPrice');
  @override
  late final GeneratedColumn<double> buyPrice = GeneratedColumn<double>(
      'buy_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _sellPriceMeta =
      const VerificationMeta('sellPrice');
  @override
  late final GeneratedColumn<double> sellPrice = GeneratedColumn<double>(
      'sell_price', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _isGallonMeta =
      const VerificationMeta('isGallon');
  @override
  late final GeneratedColumn<bool> isGallon = GeneratedColumn<bool>(
      'is_gallon', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_gallon" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<bool> active = GeneratedColumn<bool>(
      'active', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("active" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        brand,
        category,
        baseUnit,
        packUnit,
        packSize,
        buyPrice,
        sellPrice,
        isGallon,
        active
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'products';
  @override
  VerificationContext validateIntegrity(Insertable<Product> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('brand')) {
      context.handle(
          _brandMeta, brand.isAcceptableOrUnknown(data['brand']!, _brandMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    }
    if (data.containsKey('base_unit')) {
      context.handle(_baseUnitMeta,
          baseUnit.isAcceptableOrUnknown(data['base_unit']!, _baseUnitMeta));
    }
    if (data.containsKey('pack_unit')) {
      context.handle(_packUnitMeta,
          packUnit.isAcceptableOrUnknown(data['pack_unit']!, _packUnitMeta));
    }
    if (data.containsKey('pack_size')) {
      context.handle(_packSizeMeta,
          packSize.isAcceptableOrUnknown(data['pack_size']!, _packSizeMeta));
    }
    if (data.containsKey('buy_price')) {
      context.handle(_buyPriceMeta,
          buyPrice.isAcceptableOrUnknown(data['buy_price']!, _buyPriceMeta));
    }
    if (data.containsKey('sell_price')) {
      context.handle(_sellPriceMeta,
          sellPrice.isAcceptableOrUnknown(data['sell_price']!, _sellPriceMeta));
    }
    if (data.containsKey('is_gallon')) {
      context.handle(_isGallonMeta,
          isGallon.isAcceptableOrUnknown(data['is_gallon']!, _isGallonMeta));
    }
    if (data.containsKey('active')) {
      context.handle(_activeMeta,
          active.isAcceptableOrUnknown(data['active']!, _activeMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Product map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Product(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      brand: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}brand'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      baseUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}base_unit'])!,
      packUnit: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}pack_unit']),
      packSize: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}pack_size'])!,
      buyPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}buy_price'])!,
      sellPrice: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}sell_price'])!,
      isGallon: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_gallon'])!,
      active: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}active'])!,
    );
  }

  @override
  $ProductsTable createAlias(String alias) {
    return $ProductsTable(attachedDatabase, alias);
  }
}

class Product extends DataClass implements Insertable<Product> {
  final int id;
  final String name;
  final String brand;

  /// 'gallon' | 'bottle' | 'cup' | 'other'
  final String category;

  /// Base unit for all stock math, e.g. 'pcs'.
  final String baseUnit;

  /// Optional pack unit, e.g. 'box'. packSize = base units per pack.
  final String? packUnit;
  final int packSize;
  final double buyPrice;
  final double sellPrice;

  /// true = gallon product (has a circulating CONTAINER / deposit).
  /// The water still flows through normal product stock; the container
  /// flows through GallonLedger.
  final bool isGallon;
  final bool active;
  const Product(
      {required this.id,
      required this.name,
      required this.brand,
      required this.category,
      required this.baseUnit,
      this.packUnit,
      required this.packSize,
      required this.buyPrice,
      required this.sellPrice,
      required this.isGallon,
      required this.active});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['brand'] = Variable<String>(brand);
    map['category'] = Variable<String>(category);
    map['base_unit'] = Variable<String>(baseUnit);
    if (!nullToAbsent || packUnit != null) {
      map['pack_unit'] = Variable<String>(packUnit);
    }
    map['pack_size'] = Variable<int>(packSize);
    map['buy_price'] = Variable<double>(buyPrice);
    map['sell_price'] = Variable<double>(sellPrice);
    map['is_gallon'] = Variable<bool>(isGallon);
    map['active'] = Variable<bool>(active);
    return map;
  }

  ProductsCompanion toCompanion(bool nullToAbsent) {
    return ProductsCompanion(
      id: Value(id),
      name: Value(name),
      brand: Value(brand),
      category: Value(category),
      baseUnit: Value(baseUnit),
      packUnit: packUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(packUnit),
      packSize: Value(packSize),
      buyPrice: Value(buyPrice),
      sellPrice: Value(sellPrice),
      isGallon: Value(isGallon),
      active: Value(active),
    );
  }

  factory Product.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Product(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      brand: serializer.fromJson<String>(json['brand']),
      category: serializer.fromJson<String>(json['category']),
      baseUnit: serializer.fromJson<String>(json['baseUnit']),
      packUnit: serializer.fromJson<String?>(json['packUnit']),
      packSize: serializer.fromJson<int>(json['packSize']),
      buyPrice: serializer.fromJson<double>(json['buyPrice']),
      sellPrice: serializer.fromJson<double>(json['sellPrice']),
      isGallon: serializer.fromJson<bool>(json['isGallon']),
      active: serializer.fromJson<bool>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'brand': serializer.toJson<String>(brand),
      'category': serializer.toJson<String>(category),
      'baseUnit': serializer.toJson<String>(baseUnit),
      'packUnit': serializer.toJson<String?>(packUnit),
      'packSize': serializer.toJson<int>(packSize),
      'buyPrice': serializer.toJson<double>(buyPrice),
      'sellPrice': serializer.toJson<double>(sellPrice),
      'isGallon': serializer.toJson<bool>(isGallon),
      'active': serializer.toJson<bool>(active),
    };
  }

  Product copyWith(
          {int? id,
          String? name,
          String? brand,
          String? category,
          String? baseUnit,
          Value<String?> packUnit = const Value.absent(),
          int? packSize,
          double? buyPrice,
          double? sellPrice,
          bool? isGallon,
          bool? active}) =>
      Product(
        id: id ?? this.id,
        name: name ?? this.name,
        brand: brand ?? this.brand,
        category: category ?? this.category,
        baseUnit: baseUnit ?? this.baseUnit,
        packUnit: packUnit.present ? packUnit.value : this.packUnit,
        packSize: packSize ?? this.packSize,
        buyPrice: buyPrice ?? this.buyPrice,
        sellPrice: sellPrice ?? this.sellPrice,
        isGallon: isGallon ?? this.isGallon,
        active: active ?? this.active,
      );
  Product copyWithCompanion(ProductsCompanion data) {
    return Product(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      brand: data.brand.present ? data.brand.value : this.brand,
      category: data.category.present ? data.category.value : this.category,
      baseUnit: data.baseUnit.present ? data.baseUnit.value : this.baseUnit,
      packUnit: data.packUnit.present ? data.packUnit.value : this.packUnit,
      packSize: data.packSize.present ? data.packSize.value : this.packSize,
      buyPrice: data.buyPrice.present ? data.buyPrice.value : this.buyPrice,
      sellPrice: data.sellPrice.present ? data.sellPrice.value : this.sellPrice,
      isGallon: data.isGallon.present ? data.isGallon.value : this.isGallon,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Product(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('packUnit: $packUnit, ')
          ..write('packSize: $packSize, ')
          ..write('buyPrice: $buyPrice, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('isGallon: $isGallon, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, brand, category, baseUnit, packUnit,
      packSize, buyPrice, sellPrice, isGallon, active);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Product &&
          other.id == this.id &&
          other.name == this.name &&
          other.brand == this.brand &&
          other.category == this.category &&
          other.baseUnit == this.baseUnit &&
          other.packUnit == this.packUnit &&
          other.packSize == this.packSize &&
          other.buyPrice == this.buyPrice &&
          other.sellPrice == this.sellPrice &&
          other.isGallon == this.isGallon &&
          other.active == this.active);
}

class ProductsCompanion extends UpdateCompanion<Product> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> brand;
  final Value<String> category;
  final Value<String> baseUnit;
  final Value<String?> packUnit;
  final Value<int> packSize;
  final Value<double> buyPrice;
  final Value<double> sellPrice;
  final Value<bool> isGallon;
  final Value<bool> active;
  const ProductsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.packUnit = const Value.absent(),
    this.packSize = const Value.absent(),
    this.buyPrice = const Value.absent(),
    this.sellPrice = const Value.absent(),
    this.isGallon = const Value.absent(),
    this.active = const Value.absent(),
  });
  ProductsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.brand = const Value.absent(),
    this.category = const Value.absent(),
    this.baseUnit = const Value.absent(),
    this.packUnit = const Value.absent(),
    this.packSize = const Value.absent(),
    this.buyPrice = const Value.absent(),
    this.sellPrice = const Value.absent(),
    this.isGallon = const Value.absent(),
    this.active = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Product> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? brand,
    Expression<String>? category,
    Expression<String>? baseUnit,
    Expression<String>? packUnit,
    Expression<int>? packSize,
    Expression<double>? buyPrice,
    Expression<double>? sellPrice,
    Expression<bool>? isGallon,
    Expression<bool>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (brand != null) 'brand': brand,
      if (category != null) 'category': category,
      if (baseUnit != null) 'base_unit': baseUnit,
      if (packUnit != null) 'pack_unit': packUnit,
      if (packSize != null) 'pack_size': packSize,
      if (buyPrice != null) 'buy_price': buyPrice,
      if (sellPrice != null) 'sell_price': sellPrice,
      if (isGallon != null) 'is_gallon': isGallon,
      if (active != null) 'active': active,
    });
  }

  ProductsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? brand,
      Value<String>? category,
      Value<String>? baseUnit,
      Value<String?>? packUnit,
      Value<int>? packSize,
      Value<double>? buyPrice,
      Value<double>? sellPrice,
      Value<bool>? isGallon,
      Value<bool>? active}) {
    return ProductsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      baseUnit: baseUnit ?? this.baseUnit,
      packUnit: packUnit ?? this.packUnit,
      packSize: packSize ?? this.packSize,
      buyPrice: buyPrice ?? this.buyPrice,
      sellPrice: sellPrice ?? this.sellPrice,
      isGallon: isGallon ?? this.isGallon,
      active: active ?? this.active,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (brand.present) {
      map['brand'] = Variable<String>(brand.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (baseUnit.present) {
      map['base_unit'] = Variable<String>(baseUnit.value);
    }
    if (packUnit.present) {
      map['pack_unit'] = Variable<String>(packUnit.value);
    }
    if (packSize.present) {
      map['pack_size'] = Variable<int>(packSize.value);
    }
    if (buyPrice.present) {
      map['buy_price'] = Variable<double>(buyPrice.value);
    }
    if (sellPrice.present) {
      map['sell_price'] = Variable<double>(sellPrice.value);
    }
    if (isGallon.present) {
      map['is_gallon'] = Variable<bool>(isGallon.value);
    }
    if (active.present) {
      map['active'] = Variable<bool>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('brand: $brand, ')
          ..write('category: $category, ')
          ..write('baseUnit: $baseUnit, ')
          ..write('packUnit: $packUnit, ')
          ..write('packSize: $packSize, ')
          ..write('buyPrice: $buyPrice, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('isGallon: $isGallon, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTable extends Suppliers
    with TableInfo<$SuppliersTable, Supplier> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, phone, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(Insertable<Supplier> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Supplier map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Supplier(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $SuppliersTable createAlias(String alias) {
    return $SuppliersTable(attachedDatabase, alias);
  }
}

class Supplier extends DataClass implements Insertable<Supplier> {
  final int id;
  final String name;
  final String? phone;
  final String? note;
  const Supplier({required this.id, required this.name, this.phone, this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  SuppliersCompanion toCompanion(bool nullToAbsent) {
    return SuppliersCompanion(
      id: Value(id),
      name: Value(name),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Supplier.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Supplier(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'note': serializer.toJson<String?>(note),
    };
  }

  Supplier copyWith(
          {int? id,
          String? name,
          Value<String?> phone = const Value.absent(),
          Value<String?> note = const Value.absent()}) =>
      Supplier(
        id: id ?? this.id,
        name: name ?? this.name,
        phone: phone.present ? phone.value : this.phone,
        note: note.present ? note.value : this.note,
      );
  Supplier copyWithCompanion(SuppliersCompanion data) {
    return Supplier(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Supplier(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, phone, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Supplier &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.note == this.note);
}

class SuppliersCompanion extends UpdateCompanion<Supplier> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> note;
  const SuppliersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.note = const Value.absent(),
  });
  SuppliersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.note = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Supplier> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (note != null) 'note': note,
    });
  }

  SuppliersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String?>? phone,
      Value<String?>? note}) {
    return SuppliersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('general'));
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
      'phone', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, name, type, phone];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(Insertable<Customer> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    }
    if (data.containsKey('phone')) {
      context.handle(
          _phoneMeta, phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      phone: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}phone']),
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final String name;

  /// 'general' | 'subscriber' | 'reseller'
  final String type;
  final String? phone;
  const Customer(
      {required this.id, required this.name, required this.type, this.phone});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      type: Value(type),
      phone:
          phone == null && nullToAbsent ? const Value.absent() : Value(phone),
    );
  }

  factory Customer.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      type: serializer.fromJson<String>(json['type']),
      phone: serializer.fromJson<String?>(json['phone']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'type': serializer.toJson<String>(type),
      'phone': serializer.toJson<String?>(phone),
    };
  }

  Customer copyWith(
          {int? id,
          String? name,
          String? type,
          Value<String?> phone = const Value.absent()}) =>
      Customer(
        id: id ?? this.id,
        name: name ?? this.name,
        type: type ?? this.type,
        phone: phone.present ? phone.value : this.phone,
      );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      type: data.type.present ? data.type.value : this.type,
      phone: data.phone.present ? data.phone.value : this.phone,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('phone: $phone')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, type, phone);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.type == this.type &&
          other.phone == this.phone);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> type;
  final Value<String?> phone;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.type = const Value.absent(),
    this.phone = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.type = const Value.absent(),
    this.phone = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? type,
    Expression<String>? phone,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (type != null) 'type': type,
      if (phone != null) 'phone': phone,
    });
  }

  CustomersCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? type,
      Value<String?>? phone}) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      phone: phone ?? this.phone,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('type: $type, ')
          ..write('phone: $phone')
          ..write(')'))
        .toString();
  }
}

class $PurchasesTable extends Purchases
    with TableInfo<$PurchasesTable, Purchase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _supplierIdMeta =
      const VerificationMeta('supplierId');
  @override
  late final GeneratedColumn<int> supplierId = GeneratedColumn<int>(
      'supplier_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paymentStatusMeta =
      const VerificationMeta('paymentStatus');
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
      'payment_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('paid'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, supplierId, date, totalAmount, paymentStatus, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchases';
  @override
  VerificationContext validateIntegrity(Insertable<Purchase> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
          _supplierIdMeta,
          supplierId.isAcceptableOrUnknown(
              data['supplier_id']!, _supplierIdMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    }
    if (data.containsKey('payment_status')) {
      context.handle(
          _paymentStatusMeta,
          paymentStatus.isAcceptableOrUnknown(
              data['payment_status']!, _paymentStatusMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Purchase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Purchase(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      supplierId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}supplier_id']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      paymentStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_status'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $PurchasesTable createAlias(String alias) {
    return $PurchasesTable(attachedDatabase, alias);
  }
}

class Purchase extends DataClass implements Insertable<Purchase> {
  final int id;
  final int? supplierId;
  final DateTime date;
  final double totalAmount;

  /// 'paid' | 'debt'
  final String paymentStatus;
  final String? note;
  const Purchase(
      {required this.id,
      this.supplierId,
      required this.date,
      required this.totalAmount,
      required this.paymentStatus,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<int>(supplierId);
    }
    map['date'] = Variable<DateTime>(date);
    map['total_amount'] = Variable<double>(totalAmount);
    map['payment_status'] = Variable<String>(paymentStatus);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  PurchasesCompanion toCompanion(bool nullToAbsent) {
    return PurchasesCompanion(
      id: Value(id),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      date: Value(date),
      totalAmount: Value(totalAmount),
      paymentStatus: Value(paymentStatus),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Purchase.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Purchase(
      id: serializer.fromJson<int>(json['id']),
      supplierId: serializer.fromJson<int?>(json['supplierId']),
      date: serializer.fromJson<DateTime>(json['date']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'supplierId': serializer.toJson<int?>(supplierId),
      'date': serializer.toJson<DateTime>(date),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'note': serializer.toJson<String?>(note),
    };
  }

  Purchase copyWith(
          {int? id,
          Value<int?> supplierId = const Value.absent(),
          DateTime? date,
          double? totalAmount,
          String? paymentStatus,
          Value<String?> note = const Value.absent()}) =>
      Purchase(
        id: id ?? this.id,
        supplierId: supplierId.present ? supplierId.value : this.supplierId,
        date: date ?? this.date,
        totalAmount: totalAmount ?? this.totalAmount,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        note: note.present ? note.value : this.note,
      );
  Purchase copyWithCompanion(PurchasesCompanion data) {
    return Purchase(
      id: data.id.present ? data.id.value : this.id,
      supplierId:
          data.supplierId.present ? data.supplierId.value : this.supplierId,
      date: data.date.present ? data.date.value : this.date,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Purchase(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('date: $date, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, supplierId, date, totalAmount, paymentStatus, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Purchase &&
          other.id == this.id &&
          other.supplierId == this.supplierId &&
          other.date == this.date &&
          other.totalAmount == this.totalAmount &&
          other.paymentStatus == this.paymentStatus &&
          other.note == this.note);
}

class PurchasesCompanion extends UpdateCompanion<Purchase> {
  final Value<int> id;
  final Value<int?> supplierId;
  final Value<DateTime> date;
  final Value<double> totalAmount;
  final Value<String> paymentStatus;
  final Value<String?> note;
  const PurchasesCompanion({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.date = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.note = const Value.absent(),
  });
  PurchasesCompanion.insert({
    this.id = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.date = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.note = const Value.absent(),
  });
  static Insertable<Purchase> custom({
    Expression<int>? id,
    Expression<int>? supplierId,
    Expression<DateTime>? date,
    Expression<double>? totalAmount,
    Expression<String>? paymentStatus,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (supplierId != null) 'supplier_id': supplierId,
      if (date != null) 'date': date,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (note != null) 'note': note,
    });
  }

  PurchasesCompanion copyWith(
      {Value<int>? id,
      Value<int?>? supplierId,
      Value<DateTime>? date,
      Value<double>? totalAmount,
      Value<String>? paymentStatus,
      Value<String?>? note}) {
    return PurchasesCompanion(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<int>(supplierId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchasesCompanion(')
          ..write('id: $id, ')
          ..write('supplierId: $supplierId, ')
          ..write('date: $date, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $PurchaseItemsTable extends PurchaseItems
    with TableInfo<$PurchaseItemsTable, PurchaseItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PurchaseItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _purchaseIdMeta =
      const VerificationMeta('purchaseId');
  @override
  late final GeneratedColumn<int> purchaseId = GeneratedColumn<int>(
      'purchase_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _qtyBaseMeta =
      const VerificationMeta('qtyBase');
  @override
  late final GeneratedColumn<int> qtyBase = GeneratedColumn<int>(
      'qty_base', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, purchaseId, productId, qtyBase, price, subtotal];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'purchase_items';
  @override
  VerificationContext validateIntegrity(Insertable<PurchaseItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('purchase_id')) {
      context.handle(
          _purchaseIdMeta,
          purchaseId.isAcceptableOrUnknown(
              data['purchase_id']!, _purchaseIdMeta));
    } else if (isInserting) {
      context.missing(_purchaseIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('qty_base')) {
      context.handle(_qtyBaseMeta,
          qtyBase.isAcceptableOrUnknown(data['qty_base']!, _qtyBaseMeta));
    } else if (isInserting) {
      context.missing(_qtyBaseMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PurchaseItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PurchaseItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      purchaseId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}purchase_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      qtyBase: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty_base'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
    );
  }

  @override
  $PurchaseItemsTable createAlias(String alias) {
    return $PurchaseItemsTable(attachedDatabase, alias);
  }
}

class PurchaseItem extends DataClass implements Insertable<PurchaseItem> {
  final int id;
  final int purchaseId;
  final int productId;
  final int qtyBase;
  final double price;
  final double subtotal;
  const PurchaseItem(
      {required this.id,
      required this.purchaseId,
      required this.productId,
      required this.qtyBase,
      required this.price,
      required this.subtotal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['purchase_id'] = Variable<int>(purchaseId);
    map['product_id'] = Variable<int>(productId);
    map['qty_base'] = Variable<int>(qtyBase);
    map['price'] = Variable<double>(price);
    map['subtotal'] = Variable<double>(subtotal);
    return map;
  }

  PurchaseItemsCompanion toCompanion(bool nullToAbsent) {
    return PurchaseItemsCompanion(
      id: Value(id),
      purchaseId: Value(purchaseId),
      productId: Value(productId),
      qtyBase: Value(qtyBase),
      price: Value(price),
      subtotal: Value(subtotal),
    );
  }

  factory PurchaseItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PurchaseItem(
      id: serializer.fromJson<int>(json['id']),
      purchaseId: serializer.fromJson<int>(json['purchaseId']),
      productId: serializer.fromJson<int>(json['productId']),
      qtyBase: serializer.fromJson<int>(json['qtyBase']),
      price: serializer.fromJson<double>(json['price']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'purchaseId': serializer.toJson<int>(purchaseId),
      'productId': serializer.toJson<int>(productId),
      'qtyBase': serializer.toJson<int>(qtyBase),
      'price': serializer.toJson<double>(price),
      'subtotal': serializer.toJson<double>(subtotal),
    };
  }

  PurchaseItem copyWith(
          {int? id,
          int? purchaseId,
          int? productId,
          int? qtyBase,
          double? price,
          double? subtotal}) =>
      PurchaseItem(
        id: id ?? this.id,
        purchaseId: purchaseId ?? this.purchaseId,
        productId: productId ?? this.productId,
        qtyBase: qtyBase ?? this.qtyBase,
        price: price ?? this.price,
        subtotal: subtotal ?? this.subtotal,
      );
  PurchaseItem copyWithCompanion(PurchaseItemsCompanion data) {
    return PurchaseItem(
      id: data.id.present ? data.id.value : this.id,
      purchaseId:
          data.purchaseId.present ? data.purchaseId.value : this.purchaseId,
      productId: data.productId.present ? data.productId.value : this.productId,
      qtyBase: data.qtyBase.present ? data.qtyBase.value : this.qtyBase,
      price: data.price.present ? data.price.value : this.price,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseItem(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productId: $productId, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('price: $price, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, purchaseId, productId, qtyBase, price, subtotal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PurchaseItem &&
          other.id == this.id &&
          other.purchaseId == this.purchaseId &&
          other.productId == this.productId &&
          other.qtyBase == this.qtyBase &&
          other.price == this.price &&
          other.subtotal == this.subtotal);
}

class PurchaseItemsCompanion extends UpdateCompanion<PurchaseItem> {
  final Value<int> id;
  final Value<int> purchaseId;
  final Value<int> productId;
  final Value<int> qtyBase;
  final Value<double> price;
  final Value<double> subtotal;
  const PurchaseItemsCompanion({
    this.id = const Value.absent(),
    this.purchaseId = const Value.absent(),
    this.productId = const Value.absent(),
    this.qtyBase = const Value.absent(),
    this.price = const Value.absent(),
    this.subtotal = const Value.absent(),
  });
  PurchaseItemsCompanion.insert({
    this.id = const Value.absent(),
    required int purchaseId,
    required int productId,
    required int qtyBase,
    required double price,
    required double subtotal,
  })  : purchaseId = Value(purchaseId),
        productId = Value(productId),
        qtyBase = Value(qtyBase),
        price = Value(price),
        subtotal = Value(subtotal);
  static Insertable<PurchaseItem> custom({
    Expression<int>? id,
    Expression<int>? purchaseId,
    Expression<int>? productId,
    Expression<int>? qtyBase,
    Expression<double>? price,
    Expression<double>? subtotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseId != null) 'purchase_id': purchaseId,
      if (productId != null) 'product_id': productId,
      if (qtyBase != null) 'qty_base': qtyBase,
      if (price != null) 'price': price,
      if (subtotal != null) 'subtotal': subtotal,
    });
  }

  PurchaseItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? purchaseId,
      Value<int>? productId,
      Value<int>? qtyBase,
      Value<double>? price,
      Value<double>? subtotal}) {
    return PurchaseItemsCompanion(
      id: id ?? this.id,
      purchaseId: purchaseId ?? this.purchaseId,
      productId: productId ?? this.productId,
      qtyBase: qtyBase ?? this.qtyBase,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (purchaseId.present) {
      map['purchase_id'] = Variable<int>(purchaseId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (qtyBase.present) {
      map['qty_base'] = Variable<int>(qtyBase.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PurchaseItemsCompanion(')
          ..write('id: $id, ')
          ..write('purchaseId: $purchaseId, ')
          ..write('productId: $productId, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('price: $price, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }
}

class $SalesTable extends Sales with TableInfo<$SalesTable, Sale> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SalesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _totalAmountMeta =
      const VerificationMeta('totalAmount');
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
      'total_amount', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cash'));
  static const VerificationMeta _paymentStatusMeta =
      const VerificationMeta('paymentStatus');
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
      'payment_status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('paid'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, customerId, date, totalAmount, paymentMethod, paymentStatus, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sales';
  @override
  VerificationContext validateIntegrity(Insertable<Sale> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('total_amount')) {
      context.handle(
          _totalAmountMeta,
          totalAmount.isAcceptableOrUnknown(
              data['total_amount']!, _totalAmountMeta));
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    }
    if (data.containsKey('payment_status')) {
      context.handle(
          _paymentStatusMeta,
          paymentStatus.isAcceptableOrUnknown(
              data['payment_status']!, _paymentStatusMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Sale map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Sale(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}customer_id']),
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      totalAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}total_amount'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      paymentStatus: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_status'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $SalesTable createAlias(String alias) {
    return $SalesTable(attachedDatabase, alias);
  }
}

class Sale extends DataClass implements Insertable<Sale> {
  final int id;
  final int? customerId;
  final DateTime date;
  final double totalAmount;

  /// 'cash' | 'qris' | 'transfer'
  final String paymentMethod;

  /// 'paid' | 'receivable'
  final String paymentStatus;
  final String? note;
  const Sale(
      {required this.id,
      this.customerId,
      required this.date,
      required this.totalAmount,
      required this.paymentMethod,
      required this.paymentStatus,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<int>(customerId);
    }
    map['date'] = Variable<DateTime>(date);
    map['total_amount'] = Variable<double>(totalAmount);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['payment_status'] = Variable<String>(paymentStatus);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  SalesCompanion toCompanion(bool nullToAbsent) {
    return SalesCompanion(
      id: Value(id),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      date: Value(date),
      totalAmount: Value(totalAmount),
      paymentMethod: Value(paymentMethod),
      paymentStatus: Value(paymentStatus),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory Sale.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Sale(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int?>(json['customerId']),
      date: serializer.fromJson<DateTime>(json['date']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int?>(customerId),
      'date': serializer.toJson<DateTime>(date),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'note': serializer.toJson<String?>(note),
    };
  }

  Sale copyWith(
          {int? id,
          Value<int?> customerId = const Value.absent(),
          DateTime? date,
          double? totalAmount,
          String? paymentMethod,
          String? paymentStatus,
          Value<String?> note = const Value.absent()}) =>
      Sale(
        id: id ?? this.id,
        customerId: customerId.present ? customerId.value : this.customerId,
        date: date ?? this.date,
        totalAmount: totalAmount ?? this.totalAmount,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        paymentStatus: paymentStatus ?? this.paymentStatus,
        note: note.present ? note.value : this.note,
      );
  Sale copyWithCompanion(SalesCompanion data) {
    return Sale(
      id: data.id.present ? data.id.value : this.id,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      date: data.date.present ? data.date.value : this.date,
      totalAmount:
          data.totalAmount.present ? data.totalAmount.value : this.totalAmount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Sale(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('date: $date, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, customerId, date, totalAmount, paymentMethod, paymentStatus, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Sale &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.date == this.date &&
          other.totalAmount == this.totalAmount &&
          other.paymentMethod == this.paymentMethod &&
          other.paymentStatus == this.paymentStatus &&
          other.note == this.note);
}

class SalesCompanion extends UpdateCompanion<Sale> {
  final Value<int> id;
  final Value<int?> customerId;
  final Value<DateTime> date;
  final Value<double> totalAmount;
  final Value<String> paymentMethod;
  final Value<String> paymentStatus;
  final Value<String?> note;
  const SalesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.date = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.note = const Value.absent(),
  });
  SalesCompanion.insert({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.date = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.note = const Value.absent(),
  });
  static Insertable<Sale> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<DateTime>? date,
    Expression<double>? totalAmount,
    Expression<String>? paymentMethod,
    Expression<String>? paymentStatus,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (date != null) 'date': date,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (note != null) 'note': note,
    });
  }

  SalesCompanion copyWith(
      {Value<int>? id,
      Value<int?>? customerId,
      Value<DateTime>? date,
      Value<double>? totalAmount,
      Value<String>? paymentMethod,
      Value<String>? paymentStatus,
      Value<String?>? note}) {
    return SalesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      date: date ?? this.date,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SalesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('date: $date, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $SaleItemsTable extends SaleItems
    with TableInfo<$SaleItemsTable, SaleItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SaleItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _saleIdMeta = const VerificationMeta('saleId');
  @override
  late final GeneratedColumn<int> saleId = GeneratedColumn<int>(
      'sale_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _qtyBaseMeta =
      const VerificationMeta('qtyBase');
  @override
  late final GeneratedColumn<int> qtyBase = GeneratedColumn<int>(
      'qty_base', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
      'price', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _subtotalMeta =
      const VerificationMeta('subtotal');
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
      'subtotal', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, saleId, productId, qtyBase, price, subtotal];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sale_items';
  @override
  VerificationContext validateIntegrity(Insertable<SaleItem> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('sale_id')) {
      context.handle(_saleIdMeta,
          saleId.isAcceptableOrUnknown(data['sale_id']!, _saleIdMeta));
    } else if (isInserting) {
      context.missing(_saleIdMeta);
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('qty_base')) {
      context.handle(_qtyBaseMeta,
          qtyBase.isAcceptableOrUnknown(data['qty_base']!, _qtyBaseMeta));
    } else if (isInserting) {
      context.missing(_qtyBaseMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
          _priceMeta, price.isAcceptableOrUnknown(data['price']!, _priceMeta));
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(_subtotalMeta,
          subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta));
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SaleItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SaleItem(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      saleId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}sale_id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      qtyBase: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty_base'])!,
      price: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}price'])!,
      subtotal: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}subtotal'])!,
    );
  }

  @override
  $SaleItemsTable createAlias(String alias) {
    return $SaleItemsTable(attachedDatabase, alias);
  }
}

class SaleItem extends DataClass implements Insertable<SaleItem> {
  final int id;
  final int saleId;
  final int productId;
  final int qtyBase;
  final double price;
  final double subtotal;
  const SaleItem(
      {required this.id,
      required this.saleId,
      required this.productId,
      required this.qtyBase,
      required this.price,
      required this.subtotal});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['sale_id'] = Variable<int>(saleId);
    map['product_id'] = Variable<int>(productId);
    map['qty_base'] = Variable<int>(qtyBase);
    map['price'] = Variable<double>(price);
    map['subtotal'] = Variable<double>(subtotal);
    return map;
  }

  SaleItemsCompanion toCompanion(bool nullToAbsent) {
    return SaleItemsCompanion(
      id: Value(id),
      saleId: Value(saleId),
      productId: Value(productId),
      qtyBase: Value(qtyBase),
      price: Value(price),
      subtotal: Value(subtotal),
    );
  }

  factory SaleItem.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SaleItem(
      id: serializer.fromJson<int>(json['id']),
      saleId: serializer.fromJson<int>(json['saleId']),
      productId: serializer.fromJson<int>(json['productId']),
      qtyBase: serializer.fromJson<int>(json['qtyBase']),
      price: serializer.fromJson<double>(json['price']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'saleId': serializer.toJson<int>(saleId),
      'productId': serializer.toJson<int>(productId),
      'qtyBase': serializer.toJson<int>(qtyBase),
      'price': serializer.toJson<double>(price),
      'subtotal': serializer.toJson<double>(subtotal),
    };
  }

  SaleItem copyWith(
          {int? id,
          int? saleId,
          int? productId,
          int? qtyBase,
          double? price,
          double? subtotal}) =>
      SaleItem(
        id: id ?? this.id,
        saleId: saleId ?? this.saleId,
        productId: productId ?? this.productId,
        qtyBase: qtyBase ?? this.qtyBase,
        price: price ?? this.price,
        subtotal: subtotal ?? this.subtotal,
      );
  SaleItem copyWithCompanion(SaleItemsCompanion data) {
    return SaleItem(
      id: data.id.present ? data.id.value : this.id,
      saleId: data.saleId.present ? data.saleId.value : this.saleId,
      productId: data.productId.present ? data.productId.value : this.productId,
      qtyBase: data.qtyBase.present ? data.qtyBase.value : this.qtyBase,
      price: data.price.present ? data.price.value : this.price,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SaleItem(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('price: $price, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, saleId, productId, qtyBase, price, subtotal);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SaleItem &&
          other.id == this.id &&
          other.saleId == this.saleId &&
          other.productId == this.productId &&
          other.qtyBase == this.qtyBase &&
          other.price == this.price &&
          other.subtotal == this.subtotal);
}

class SaleItemsCompanion extends UpdateCompanion<SaleItem> {
  final Value<int> id;
  final Value<int> saleId;
  final Value<int> productId;
  final Value<int> qtyBase;
  final Value<double> price;
  final Value<double> subtotal;
  const SaleItemsCompanion({
    this.id = const Value.absent(),
    this.saleId = const Value.absent(),
    this.productId = const Value.absent(),
    this.qtyBase = const Value.absent(),
    this.price = const Value.absent(),
    this.subtotal = const Value.absent(),
  });
  SaleItemsCompanion.insert({
    this.id = const Value.absent(),
    required int saleId,
    required int productId,
    required int qtyBase,
    required double price,
    required double subtotal,
  })  : saleId = Value(saleId),
        productId = Value(productId),
        qtyBase = Value(qtyBase),
        price = Value(price),
        subtotal = Value(subtotal);
  static Insertable<SaleItem> custom({
    Expression<int>? id,
    Expression<int>? saleId,
    Expression<int>? productId,
    Expression<int>? qtyBase,
    Expression<double>? price,
    Expression<double>? subtotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (saleId != null) 'sale_id': saleId,
      if (productId != null) 'product_id': productId,
      if (qtyBase != null) 'qty_base': qtyBase,
      if (price != null) 'price': price,
      if (subtotal != null) 'subtotal': subtotal,
    });
  }

  SaleItemsCompanion copyWith(
      {Value<int>? id,
      Value<int>? saleId,
      Value<int>? productId,
      Value<int>? qtyBase,
      Value<double>? price,
      Value<double>? subtotal}) {
    return SaleItemsCompanion(
      id: id ?? this.id,
      saleId: saleId ?? this.saleId,
      productId: productId ?? this.productId,
      qtyBase: qtyBase ?? this.qtyBase,
      price: price ?? this.price,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (saleId.present) {
      map['sale_id'] = Variable<int>(saleId.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (qtyBase.present) {
      map['qty_base'] = Variable<int>(qtyBase.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SaleItemsCompanion(')
          ..write('id: $id, ')
          ..write('saleId: $saleId, ')
          ..write('productId: $productId, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('price: $price, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }
}

class $StockMovementsTable extends StockMovements
    with TableInfo<$StockMovementsTable, StockMovement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StockMovementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _productIdMeta =
      const VerificationMeta('productId');
  @override
  late final GeneratedColumn<int> productId = GeneratedColumn<int>(
      'product_id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _qtyBaseMeta =
      const VerificationMeta('qtyBase');
  @override
  late final GeneratedColumn<int> qtyBase = GeneratedColumn<int>(
      'qty_base', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _refTypeMeta =
      const VerificationMeta('refType');
  @override
  late final GeneratedColumn<String> refType = GeneratedColumn<String>(
      'ref_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<int> refId = GeneratedColumn<int>(
      'ref_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, productId, date, type, qtyBase, refType, refId, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stock_movements';
  @override
  VerificationContext validateIntegrity(Insertable<StockMovement> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('product_id')) {
      context.handle(_productIdMeta,
          productId.isAcceptableOrUnknown(data['product_id']!, _productIdMeta));
    } else if (isInserting) {
      context.missing(_productIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('qty_base')) {
      context.handle(_qtyBaseMeta,
          qtyBase.isAcceptableOrUnknown(data['qty_base']!, _qtyBaseMeta));
    } else if (isInserting) {
      context.missing(_qtyBaseMeta);
    }
    if (data.containsKey('ref_type')) {
      context.handle(_refTypeMeta,
          refType.isAcceptableOrUnknown(data['ref_type']!, _refTypeMeta));
    }
    if (data.containsKey('ref_id')) {
      context.handle(
          _refIdMeta, refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  StockMovement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StockMovement(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      productId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}product_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      qtyBase: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}qty_base'])!,
      refType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ref_type']),
      refId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ref_id']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $StockMovementsTable createAlias(String alias) {
    return $StockMovementsTable(attachedDatabase, alias);
  }
}

class StockMovement extends DataClass implements Insertable<StockMovement> {
  final int id;
  final int productId;
  final DateTime date;

  /// 'purchase' | 'sale' | 'adjustment' | 'return'
  final String type;

  /// Signed: + in, - out (in base units).
  final int qtyBase;
  final String? refType;
  final int? refId;
  final String? note;
  const StockMovement(
      {required this.id,
      required this.productId,
      required this.date,
      required this.type,
      required this.qtyBase,
      this.refType,
      this.refId,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['product_id'] = Variable<int>(productId);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    map['qty_base'] = Variable<int>(qtyBase);
    if (!nullToAbsent || refType != null) {
      map['ref_type'] = Variable<String>(refType);
    }
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<int>(refId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  StockMovementsCompanion toCompanion(bool nullToAbsent) {
    return StockMovementsCompanion(
      id: Value(id),
      productId: Value(productId),
      date: Value(date),
      type: Value(type),
      qtyBase: Value(qtyBase),
      refType: refType == null && nullToAbsent
          ? const Value.absent()
          : Value(refType),
      refId:
          refId == null && nullToAbsent ? const Value.absent() : Value(refId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory StockMovement.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StockMovement(
      id: serializer.fromJson<int>(json['id']),
      productId: serializer.fromJson<int>(json['productId']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      qtyBase: serializer.fromJson<int>(json['qtyBase']),
      refType: serializer.fromJson<String?>(json['refType']),
      refId: serializer.fromJson<int?>(json['refId']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'productId': serializer.toJson<int>(productId),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'qtyBase': serializer.toJson<int>(qtyBase),
      'refType': serializer.toJson<String?>(refType),
      'refId': serializer.toJson<int?>(refId),
      'note': serializer.toJson<String?>(note),
    };
  }

  StockMovement copyWith(
          {int? id,
          int? productId,
          DateTime? date,
          String? type,
          int? qtyBase,
          Value<String?> refType = const Value.absent(),
          Value<int?> refId = const Value.absent(),
          Value<String?> note = const Value.absent()}) =>
      StockMovement(
        id: id ?? this.id,
        productId: productId ?? this.productId,
        date: date ?? this.date,
        type: type ?? this.type,
        qtyBase: qtyBase ?? this.qtyBase,
        refType: refType.present ? refType.value : this.refType,
        refId: refId.present ? refId.value : this.refId,
        note: note.present ? note.value : this.note,
      );
  StockMovement copyWithCompanion(StockMovementsCompanion data) {
    return StockMovement(
      id: data.id.present ? data.id.value : this.id,
      productId: data.productId.present ? data.productId.value : this.productId,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      qtyBase: data.qtyBase.present ? data.qtyBase.value : this.qtyBase,
      refType: data.refType.present ? data.refType.value : this.refType,
      refId: data.refId.present ? data.refId.value : this.refId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StockMovement(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, productId, date, type, qtyBase, refType, refId, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StockMovement &&
          other.id == this.id &&
          other.productId == this.productId &&
          other.date == this.date &&
          other.type == this.type &&
          other.qtyBase == this.qtyBase &&
          other.refType == this.refType &&
          other.refId == this.refId &&
          other.note == this.note);
}

class StockMovementsCompanion extends UpdateCompanion<StockMovement> {
  final Value<int> id;
  final Value<int> productId;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<int> qtyBase;
  final Value<String?> refType;
  final Value<int?> refId;
  final Value<String?> note;
  const StockMovementsCompanion({
    this.id = const Value.absent(),
    this.productId = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.qtyBase = const Value.absent(),
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.note = const Value.absent(),
  });
  StockMovementsCompanion.insert({
    this.id = const Value.absent(),
    required int productId,
    this.date = const Value.absent(),
    required String type,
    required int qtyBase,
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.note = const Value.absent(),
  })  : productId = Value(productId),
        type = Value(type),
        qtyBase = Value(qtyBase);
  static Insertable<StockMovement> custom({
    Expression<int>? id,
    Expression<int>? productId,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<int>? qtyBase,
    Expression<String>? refType,
    Expression<int>? refId,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (productId != null) 'product_id': productId,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (qtyBase != null) 'qty_base': qtyBase,
      if (refType != null) 'ref_type': refType,
      if (refId != null) 'ref_id': refId,
      if (note != null) 'note': note,
    });
  }

  StockMovementsCompanion copyWith(
      {Value<int>? id,
      Value<int>? productId,
      Value<DateTime>? date,
      Value<String>? type,
      Value<int>? qtyBase,
      Value<String?>? refType,
      Value<int?>? refId,
      Value<String?>? note}) {
    return StockMovementsCompanion(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      date: date ?? this.date,
      type: type ?? this.type,
      qtyBase: qtyBase ?? this.qtyBase,
      refType: refType ?? this.refType,
      refId: refId ?? this.refId,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (productId.present) {
      map['product_id'] = Variable<int>(productId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (qtyBase.present) {
      map['qty_base'] = Variable<int>(qtyBase.value);
    }
    if (refType.present) {
      map['ref_type'] = Variable<String>(refType.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<int>(refId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StockMovementsCompanion(')
          ..write('id: $id, ')
          ..write('productId: $productId, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('qtyBase: $qtyBase, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $CashEntriesTable extends CashEntries
    with TableInfo<$CashEntriesTable, CashEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _directionMeta =
      const VerificationMeta('direction');
  @override
  late final GeneratedColumn<String> direction = GeneratedColumn<String>(
      'direction', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _accountMeta =
      const VerificationMeta('account');
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
      'account', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cash'));
  static const VerificationMeta _refTypeMeta =
      const VerificationMeta('refType');
  @override
  late final GeneratedColumn<String> refType = GeneratedColumn<String>(
      'ref_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<int> refId = GeneratedColumn<int>(
      'ref_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, direction, amount, category, account, refType, refId, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cash_entries';
  @override
  VerificationContext validateIntegrity(Insertable<CashEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('direction')) {
      context.handle(_directionMeta,
          direction.isAcceptableOrUnknown(data['direction']!, _directionMeta));
    } else if (isInserting) {
      context.missing(_directionMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('account')) {
      context.handle(_accountMeta,
          account.isAcceptableOrUnknown(data['account']!, _accountMeta));
    }
    if (data.containsKey('ref_type')) {
      context.handle(_refTypeMeta,
          refType.isAcceptableOrUnknown(data['ref_type']!, _refTypeMeta));
    }
    if (data.containsKey('ref_id')) {
      context.handle(
          _refIdMeta, refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      direction: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}direction'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      account: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account'])!,
      refType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ref_type']),
      refId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ref_id']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $CashEntriesTable createAlias(String alias) {
    return $CashEntriesTable(attachedDatabase, alias);
  }
}

class CashEntry extends DataClass implements Insertable<CashEntry> {
  final int id;
  final DateTime date;

  /// 'in' | 'out'
  final String direction;
  final double amount;

  /// 'sale' | 'purchase' | 'expense' | 'capital' | 'drawing' | 'gallon_deposit'
  /// | 'adjustment' (cashier-closing difference, see CashierClosings)
  final String category;

  /// 'cash' | 'bank' | 'qris'
  final String account;
  final String? refType;
  final int? refId;
  final String? note;
  const CashEntry(
      {required this.id,
      required this.date,
      required this.direction,
      required this.amount,
      required this.category,
      required this.account,
      this.refType,
      this.refId,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['direction'] = Variable<String>(direction);
    map['amount'] = Variable<double>(amount);
    map['category'] = Variable<String>(category);
    map['account'] = Variable<String>(account);
    if (!nullToAbsent || refType != null) {
      map['ref_type'] = Variable<String>(refType);
    }
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<int>(refId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  CashEntriesCompanion toCompanion(bool nullToAbsent) {
    return CashEntriesCompanion(
      id: Value(id),
      date: Value(date),
      direction: Value(direction),
      amount: Value(amount),
      category: Value(category),
      account: Value(account),
      refType: refType == null && nullToAbsent
          ? const Value.absent()
          : Value(refType),
      refId:
          refId == null && nullToAbsent ? const Value.absent() : Value(refId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory CashEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashEntry(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      direction: serializer.fromJson<String>(json['direction']),
      amount: serializer.fromJson<double>(json['amount']),
      category: serializer.fromJson<String>(json['category']),
      account: serializer.fromJson<String>(json['account']),
      refType: serializer.fromJson<String?>(json['refType']),
      refId: serializer.fromJson<int?>(json['refId']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'direction': serializer.toJson<String>(direction),
      'amount': serializer.toJson<double>(amount),
      'category': serializer.toJson<String>(category),
      'account': serializer.toJson<String>(account),
      'refType': serializer.toJson<String?>(refType),
      'refId': serializer.toJson<int?>(refId),
      'note': serializer.toJson<String?>(note),
    };
  }

  CashEntry copyWith(
          {int? id,
          DateTime? date,
          String? direction,
          double? amount,
          String? category,
          String? account,
          Value<String?> refType = const Value.absent(),
          Value<int?> refId = const Value.absent(),
          Value<String?> note = const Value.absent()}) =>
      CashEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        direction: direction ?? this.direction,
        amount: amount ?? this.amount,
        category: category ?? this.category,
        account: account ?? this.account,
        refType: refType.present ? refType.value : this.refType,
        refId: refId.present ? refId.value : this.refId,
        note: note.present ? note.value : this.note,
      );
  CashEntry copyWithCompanion(CashEntriesCompanion data) {
    return CashEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      direction: data.direction.present ? data.direction.value : this.direction,
      amount: data.amount.present ? data.amount.value : this.amount,
      category: data.category.present ? data.category.value : this.category,
      account: data.account.present ? data.account.value : this.account,
      refType: data.refType.present ? data.refType.value : this.refType,
      refId: data.refId.present ? data.refId.value : this.refId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('direction: $direction, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('account: $account, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, date, direction, amount, category, account, refType, refId, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.direction == this.direction &&
          other.amount == this.amount &&
          other.category == this.category &&
          other.account == this.account &&
          other.refType == this.refType &&
          other.refId == this.refId &&
          other.note == this.note);
}

class CashEntriesCompanion extends UpdateCompanion<CashEntry> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> direction;
  final Value<double> amount;
  final Value<String> category;
  final Value<String> account;
  final Value<String?> refType;
  final Value<int?> refId;
  final Value<String?> note;
  const CashEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.direction = const Value.absent(),
    this.amount = const Value.absent(),
    this.category = const Value.absent(),
    this.account = const Value.absent(),
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.note = const Value.absent(),
  });
  CashEntriesCompanion.insert({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    required String direction,
    required double amount,
    required String category,
    this.account = const Value.absent(),
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.note = const Value.absent(),
  })  : direction = Value(direction),
        amount = Value(amount),
        category = Value(category);
  static Insertable<CashEntry> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? direction,
    Expression<double>? amount,
    Expression<String>? category,
    Expression<String>? account,
    Expression<String>? refType,
    Expression<int>? refId,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (direction != null) 'direction': direction,
      if (amount != null) 'amount': amount,
      if (category != null) 'category': category,
      if (account != null) 'account': account,
      if (refType != null) 'ref_type': refType,
      if (refId != null) 'ref_id': refId,
      if (note != null) 'note': note,
    });
  }

  CashEntriesCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<String>? direction,
      Value<double>? amount,
      Value<String>? category,
      Value<String>? account,
      Value<String?>? refType,
      Value<int?>? refId,
      Value<String?>? note}) {
    return CashEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      direction: direction ?? this.direction,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      account: account ?? this.account,
      refType: refType ?? this.refType,
      refId: refId ?? this.refId,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (direction.present) {
      map['direction'] = Variable<String>(direction.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (refType.present) {
      map['ref_type'] = Variable<String>(refType.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<int>(refId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('direction: $direction, ')
          ..write('amount: $amount, ')
          ..write('category: $category, ')
          ..write('account: $account, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $GallonLedgerTable extends GallonLedger
    with TableInfo<$GallonLedgerTable, GallonLedgerData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GallonLedgerTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
      'type', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dFullMeta = const VerificationMeta('dFull');
  @override
  late final GeneratedColumn<int> dFull = GeneratedColumn<int>(
      'd_full', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _dEmptyMeta = const VerificationMeta('dEmpty');
  @override
  late final GeneratedColumn<int> dEmpty = GeneratedColumn<int>(
      'd_empty', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _dDepositMeta =
      const VerificationMeta('dDeposit');
  @override
  late final GeneratedColumn<int> dDeposit = GeneratedColumn<int>(
      'd_deposit', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _customerIdMeta =
      const VerificationMeta('customerId');
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
      'customer_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _refTypeMeta =
      const VerificationMeta('refType');
  @override
  late final GeneratedColumn<String> refType = GeneratedColumn<String>(
      'ref_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _refIdMeta = const VerificationMeta('refId');
  @override
  late final GeneratedColumn<int> refId = GeneratedColumn<int>(
      'ref_id', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        date,
        type,
        dFull,
        dEmpty,
        dDeposit,
        customerId,
        refType,
        refId,
        note
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'gallon_ledger';
  @override
  VerificationContext validateIntegrity(Insertable<GallonLedgerData> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    }
    if (data.containsKey('type')) {
      context.handle(
          _typeMeta, type.isAcceptableOrUnknown(data['type']!, _typeMeta));
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('d_full')) {
      context.handle(
          _dFullMeta, dFull.isAcceptableOrUnknown(data['d_full']!, _dFullMeta));
    }
    if (data.containsKey('d_empty')) {
      context.handle(_dEmptyMeta,
          dEmpty.isAcceptableOrUnknown(data['d_empty']!, _dEmptyMeta));
    }
    if (data.containsKey('d_deposit')) {
      context.handle(_dDepositMeta,
          dDeposit.isAcceptableOrUnknown(data['d_deposit']!, _dDepositMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
          _customerIdMeta,
          customerId.isAcceptableOrUnknown(
              data['customer_id']!, _customerIdMeta));
    }
    if (data.containsKey('ref_type')) {
      context.handle(_refTypeMeta,
          refType.isAcceptableOrUnknown(data['ref_type']!, _refTypeMeta));
    }
    if (data.containsKey('ref_id')) {
      context.handle(
          _refIdMeta, refId.isAcceptableOrUnknown(data['ref_id']!, _refIdMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GallonLedgerData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GallonLedgerData(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      type: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}type'])!,
      dFull: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}d_full'])!,
      dEmpty: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}d_empty'])!,
      dDeposit: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}d_deposit'])!,
      customerId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}customer_id']),
      refType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}ref_type']),
      refId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}ref_id']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $GallonLedgerTable createAlias(String alias) {
    return $GallonLedgerTable(attachedDatabase, alias);
  }
}

class GallonLedgerData extends DataClass
    implements Insertable<GallonLedgerData> {
  final int id;
  final DateTime date;

  /// 'restock' | 'sale_exchange' | 'sale_new' | 'deposit_return' | 'adjustment'
  final String type;
  final int dFull;
  final int dEmpty;
  final int dDeposit;
  final int? customerId;
  final String? refType;
  final int? refId;
  final String? note;
  const GallonLedgerData(
      {required this.id,
      required this.date,
      required this.type,
      required this.dFull,
      required this.dEmpty,
      required this.dDeposit,
      this.customerId,
      this.refType,
      this.refId,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<DateTime>(date);
    map['type'] = Variable<String>(type);
    map['d_full'] = Variable<int>(dFull);
    map['d_empty'] = Variable<int>(dEmpty);
    map['d_deposit'] = Variable<int>(dDeposit);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<int>(customerId);
    }
    if (!nullToAbsent || refType != null) {
      map['ref_type'] = Variable<String>(refType);
    }
    if (!nullToAbsent || refId != null) {
      map['ref_id'] = Variable<int>(refId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  GallonLedgerCompanion toCompanion(bool nullToAbsent) {
    return GallonLedgerCompanion(
      id: Value(id),
      date: Value(date),
      type: Value(type),
      dFull: Value(dFull),
      dEmpty: Value(dEmpty),
      dDeposit: Value(dDeposit),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      refType: refType == null && nullToAbsent
          ? const Value.absent()
          : Value(refType),
      refId:
          refId == null && nullToAbsent ? const Value.absent() : Value(refId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory GallonLedgerData.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GallonLedgerData(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      type: serializer.fromJson<String>(json['type']),
      dFull: serializer.fromJson<int>(json['dFull']),
      dEmpty: serializer.fromJson<int>(json['dEmpty']),
      dDeposit: serializer.fromJson<int>(json['dDeposit']),
      customerId: serializer.fromJson<int?>(json['customerId']),
      refType: serializer.fromJson<String?>(json['refType']),
      refId: serializer.fromJson<int?>(json['refId']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<DateTime>(date),
      'type': serializer.toJson<String>(type),
      'dFull': serializer.toJson<int>(dFull),
      'dEmpty': serializer.toJson<int>(dEmpty),
      'dDeposit': serializer.toJson<int>(dDeposit),
      'customerId': serializer.toJson<int?>(customerId),
      'refType': serializer.toJson<String?>(refType),
      'refId': serializer.toJson<int?>(refId),
      'note': serializer.toJson<String?>(note),
    };
  }

  GallonLedgerData copyWith(
          {int? id,
          DateTime? date,
          String? type,
          int? dFull,
          int? dEmpty,
          int? dDeposit,
          Value<int?> customerId = const Value.absent(),
          Value<String?> refType = const Value.absent(),
          Value<int?> refId = const Value.absent(),
          Value<String?> note = const Value.absent()}) =>
      GallonLedgerData(
        id: id ?? this.id,
        date: date ?? this.date,
        type: type ?? this.type,
        dFull: dFull ?? this.dFull,
        dEmpty: dEmpty ?? this.dEmpty,
        dDeposit: dDeposit ?? this.dDeposit,
        customerId: customerId.present ? customerId.value : this.customerId,
        refType: refType.present ? refType.value : this.refType,
        refId: refId.present ? refId.value : this.refId,
        note: note.present ? note.value : this.note,
      );
  GallonLedgerData copyWithCompanion(GallonLedgerCompanion data) {
    return GallonLedgerData(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      type: data.type.present ? data.type.value : this.type,
      dFull: data.dFull.present ? data.dFull.value : this.dFull,
      dEmpty: data.dEmpty.present ? data.dEmpty.value : this.dEmpty,
      dDeposit: data.dDeposit.present ? data.dDeposit.value : this.dDeposit,
      customerId:
          data.customerId.present ? data.customerId.value : this.customerId,
      refType: data.refType.present ? data.refType.value : this.refType,
      refId: data.refId.present ? data.refId.value : this.refId,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GallonLedgerData(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('dFull: $dFull, ')
          ..write('dEmpty: $dEmpty, ')
          ..write('dDeposit: $dDeposit, ')
          ..write('customerId: $customerId, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, type, dFull, dEmpty, dDeposit,
      customerId, refType, refId, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GallonLedgerData &&
          other.id == this.id &&
          other.date == this.date &&
          other.type == this.type &&
          other.dFull == this.dFull &&
          other.dEmpty == this.dEmpty &&
          other.dDeposit == this.dDeposit &&
          other.customerId == this.customerId &&
          other.refType == this.refType &&
          other.refId == this.refId &&
          other.note == this.note);
}

class GallonLedgerCompanion extends UpdateCompanion<GallonLedgerData> {
  final Value<int> id;
  final Value<DateTime> date;
  final Value<String> type;
  final Value<int> dFull;
  final Value<int> dEmpty;
  final Value<int> dDeposit;
  final Value<int?> customerId;
  final Value<String?> refType;
  final Value<int?> refId;
  final Value<String?> note;
  const GallonLedgerCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.type = const Value.absent(),
    this.dFull = const Value.absent(),
    this.dEmpty = const Value.absent(),
    this.dDeposit = const Value.absent(),
    this.customerId = const Value.absent(),
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.note = const Value.absent(),
  });
  GallonLedgerCompanion.insert({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    required String type,
    this.dFull = const Value.absent(),
    this.dEmpty = const Value.absent(),
    this.dDeposit = const Value.absent(),
    this.customerId = const Value.absent(),
    this.refType = const Value.absent(),
    this.refId = const Value.absent(),
    this.note = const Value.absent(),
  }) : type = Value(type);
  static Insertable<GallonLedgerData> custom({
    Expression<int>? id,
    Expression<DateTime>? date,
    Expression<String>? type,
    Expression<int>? dFull,
    Expression<int>? dEmpty,
    Expression<int>? dDeposit,
    Expression<int>? customerId,
    Expression<String>? refType,
    Expression<int>? refId,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (type != null) 'type': type,
      if (dFull != null) 'd_full': dFull,
      if (dEmpty != null) 'd_empty': dEmpty,
      if (dDeposit != null) 'd_deposit': dDeposit,
      if (customerId != null) 'customer_id': customerId,
      if (refType != null) 'ref_type': refType,
      if (refId != null) 'ref_id': refId,
      if (note != null) 'note': note,
    });
  }

  GallonLedgerCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? date,
      Value<String>? type,
      Value<int>? dFull,
      Value<int>? dEmpty,
      Value<int>? dDeposit,
      Value<int?>? customerId,
      Value<String?>? refType,
      Value<int?>? refId,
      Value<String?>? note}) {
    return GallonLedgerCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      type: type ?? this.type,
      dFull: dFull ?? this.dFull,
      dEmpty: dEmpty ?? this.dEmpty,
      dDeposit: dDeposit ?? this.dDeposit,
      customerId: customerId ?? this.customerId,
      refType: refType ?? this.refType,
      refId: refId ?? this.refId,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (dFull.present) {
      map['d_full'] = Variable<int>(dFull.value);
    }
    if (dEmpty.present) {
      map['d_empty'] = Variable<int>(dEmpty.value);
    }
    if (dDeposit.present) {
      map['d_deposit'] = Variable<int>(dDeposit.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (refType.present) {
      map['ref_type'] = Variable<String>(refType.value);
    }
    if (refId.present) {
      map['ref_id'] = Variable<int>(refId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GallonLedgerCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('type: $type, ')
          ..write('dFull: $dFull, ')
          ..write('dEmpty: $dEmpty, ')
          ..write('dDeposit: $dDeposit, ')
          ..write('customerId: $customerId, ')
          ..write('refType: $refType, ')
          ..write('refId: $refId, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $CashierClosingsTable extends CashierClosings
    with TableInfo<$CashierClosingsTable, CashierClosing> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CashierClosingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _closedAtMeta =
      const VerificationMeta('closedAt');
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
      'closed_at', aliasedName, false,
      type: DriftSqlType.dateTime,
      requiredDuringInsert: false,
      defaultValue: currentDateAndTime);
  static const VerificationMeta _accountMeta =
      const VerificationMeta('account');
  @override
  late final GeneratedColumn<String> account = GeneratedColumn<String>(
      'account', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('cash'));
  static const VerificationMeta _systemBalanceMeta =
      const VerificationMeta('systemBalance');
  @override
  late final GeneratedColumn<double> systemBalance = GeneratedColumn<double>(
      'system_balance', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _physicalCountMeta =
      const VerificationMeta('physicalCount');
  @override
  late final GeneratedColumn<double> physicalCount = GeneratedColumn<double>(
      'physical_count', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _differenceMeta =
      const VerificationMeta('difference');
  @override
  late final GeneratedColumn<double> difference = GeneratedColumn<double>(
      'difference', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, closedAt, account, systemBalance, physicalCount, difference, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cashier_closings';
  @override
  VerificationContext validateIntegrity(Insertable<CashierClosing> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('closed_at')) {
      context.handle(_closedAtMeta,
          closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta));
    }
    if (data.containsKey('account')) {
      context.handle(_accountMeta,
          account.isAcceptableOrUnknown(data['account']!, _accountMeta));
    }
    if (data.containsKey('system_balance')) {
      context.handle(
          _systemBalanceMeta,
          systemBalance.isAcceptableOrUnknown(
              data['system_balance']!, _systemBalanceMeta));
    } else if (isInserting) {
      context.missing(_systemBalanceMeta);
    }
    if (data.containsKey('physical_count')) {
      context.handle(
          _physicalCountMeta,
          physicalCount.isAcceptableOrUnknown(
              data['physical_count']!, _physicalCountMeta));
    } else if (isInserting) {
      context.missing(_physicalCountMeta);
    }
    if (data.containsKey('difference')) {
      context.handle(
          _differenceMeta,
          difference.isAcceptableOrUnknown(
              data['difference']!, _differenceMeta));
    } else if (isInserting) {
      context.missing(_differenceMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CashierClosing map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CashierClosing(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      closedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}closed_at'])!,
      account: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}account'])!,
      systemBalance: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}system_balance'])!,
      physicalCount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}physical_count'])!,
      difference: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}difference'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $CashierClosingsTable createAlias(String alias) {
    return $CashierClosingsTable(attachedDatabase, alias);
  }
}

class CashierClosing extends DataClass implements Insertable<CashierClosing> {
  final int id;
  final DateTime closedAt;
  final String account;
  final double systemBalance;
  final double physicalCount;
  final double difference;
  final String? note;
  const CashierClosing(
      {required this.id,
      required this.closedAt,
      required this.account,
      required this.systemBalance,
      required this.physicalCount,
      required this.difference,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['closed_at'] = Variable<DateTime>(closedAt);
    map['account'] = Variable<String>(account);
    map['system_balance'] = Variable<double>(systemBalance);
    map['physical_count'] = Variable<double>(physicalCount);
    map['difference'] = Variable<double>(difference);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  CashierClosingsCompanion toCompanion(bool nullToAbsent) {
    return CashierClosingsCompanion(
      id: Value(id),
      closedAt: Value(closedAt),
      account: Value(account),
      systemBalance: Value(systemBalance),
      physicalCount: Value(physicalCount),
      difference: Value(difference),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory CashierClosing.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CashierClosing(
      id: serializer.fromJson<int>(json['id']),
      closedAt: serializer.fromJson<DateTime>(json['closedAt']),
      account: serializer.fromJson<String>(json['account']),
      systemBalance: serializer.fromJson<double>(json['systemBalance']),
      physicalCount: serializer.fromJson<double>(json['physicalCount']),
      difference: serializer.fromJson<double>(json['difference']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'closedAt': serializer.toJson<DateTime>(closedAt),
      'account': serializer.toJson<String>(account),
      'systemBalance': serializer.toJson<double>(systemBalance),
      'physicalCount': serializer.toJson<double>(physicalCount),
      'difference': serializer.toJson<double>(difference),
      'note': serializer.toJson<String?>(note),
    };
  }

  CashierClosing copyWith(
          {int? id,
          DateTime? closedAt,
          String? account,
          double? systemBalance,
          double? physicalCount,
          double? difference,
          Value<String?> note = const Value.absent()}) =>
      CashierClosing(
        id: id ?? this.id,
        closedAt: closedAt ?? this.closedAt,
        account: account ?? this.account,
        systemBalance: systemBalance ?? this.systemBalance,
        physicalCount: physicalCount ?? this.physicalCount,
        difference: difference ?? this.difference,
        note: note.present ? note.value : this.note,
      );
  CashierClosing copyWithCompanion(CashierClosingsCompanion data) {
    return CashierClosing(
      id: data.id.present ? data.id.value : this.id,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
      account: data.account.present ? data.account.value : this.account,
      systemBalance: data.systemBalance.present
          ? data.systemBalance.value
          : this.systemBalance,
      physicalCount: data.physicalCount.present
          ? data.physicalCount.value
          : this.physicalCount,
      difference:
          data.difference.present ? data.difference.value : this.difference,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CashierClosing(')
          ..write('id: $id, ')
          ..write('closedAt: $closedAt, ')
          ..write('account: $account, ')
          ..write('systemBalance: $systemBalance, ')
          ..write('physicalCount: $physicalCount, ')
          ..write('difference: $difference, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, closedAt, account, systemBalance, physicalCount, difference, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CashierClosing &&
          other.id == this.id &&
          other.closedAt == this.closedAt &&
          other.account == this.account &&
          other.systemBalance == this.systemBalance &&
          other.physicalCount == this.physicalCount &&
          other.difference == this.difference &&
          other.note == this.note);
}

class CashierClosingsCompanion extends UpdateCompanion<CashierClosing> {
  final Value<int> id;
  final Value<DateTime> closedAt;
  final Value<String> account;
  final Value<double> systemBalance;
  final Value<double> physicalCount;
  final Value<double> difference;
  final Value<String?> note;
  const CashierClosingsCompanion({
    this.id = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.account = const Value.absent(),
    this.systemBalance = const Value.absent(),
    this.physicalCount = const Value.absent(),
    this.difference = const Value.absent(),
    this.note = const Value.absent(),
  });
  CashierClosingsCompanion.insert({
    this.id = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.account = const Value.absent(),
    required double systemBalance,
    required double physicalCount,
    required double difference,
    this.note = const Value.absent(),
  })  : systemBalance = Value(systemBalance),
        physicalCount = Value(physicalCount),
        difference = Value(difference);
  static Insertable<CashierClosing> custom({
    Expression<int>? id,
    Expression<DateTime>? closedAt,
    Expression<String>? account,
    Expression<double>? systemBalance,
    Expression<double>? physicalCount,
    Expression<double>? difference,
    Expression<String>? note,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (closedAt != null) 'closed_at': closedAt,
      if (account != null) 'account': account,
      if (systemBalance != null) 'system_balance': systemBalance,
      if (physicalCount != null) 'physical_count': physicalCount,
      if (difference != null) 'difference': difference,
      if (note != null) 'note': note,
    });
  }

  CashierClosingsCompanion copyWith(
      {Value<int>? id,
      Value<DateTime>? closedAt,
      Value<String>? account,
      Value<double>? systemBalance,
      Value<double>? physicalCount,
      Value<double>? difference,
      Value<String?>? note}) {
    return CashierClosingsCompanion(
      id: id ?? this.id,
      closedAt: closedAt ?? this.closedAt,
      account: account ?? this.account,
      systemBalance: systemBalance ?? this.systemBalance,
      physicalCount: physicalCount ?? this.physicalCount,
      difference: difference ?? this.difference,
      note: note ?? this.note,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (account.present) {
      map['account'] = Variable<String>(account.value);
    }
    if (systemBalance.present) {
      map['system_balance'] = Variable<double>(systemBalance.value);
    }
    if (physicalCount.present) {
      map['physical_count'] = Variable<double>(physicalCount.value);
    }
    if (difference.present) {
      map['difference'] = Variable<double>(difference.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CashierClosingsCompanion(')
          ..write('id: $id, ')
          ..write('closedAt: $closedAt, ')
          ..write('account: $account, ')
          ..write('systemBalance: $systemBalance, ')
          ..write('physicalCount: $physicalCount, ')
          ..write('difference: $difference, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }
}

class $SyncCursorsTable extends SyncCursors
    with TableInfo<$SyncCursorsTable, SyncCursor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncCursorsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _entityMeta = const VerificationMeta('entity');
  @override
  late final GeneratedColumn<String> entity = GeneratedColumn<String>(
      'entity', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _lastIdMeta = const VerificationMeta('lastId');
  @override
  late final GeneratedColumn<int> lastId = GeneratedColumn<int>(
      'last_id', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  @override
  List<GeneratedColumn> get $columns => [entity, lastId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_cursors';
  @override
  VerificationContext validateIntegrity(Insertable<SyncCursor> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('entity')) {
      context.handle(_entityMeta,
          entity.isAcceptableOrUnknown(data['entity']!, _entityMeta));
    } else if (isInserting) {
      context.missing(_entityMeta);
    }
    if (data.containsKey('last_id')) {
      context.handle(_lastIdMeta,
          lastId.isAcceptableOrUnknown(data['last_id']!, _lastIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {entity};
  @override
  SyncCursor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncCursor(
      entity: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}entity'])!,
      lastId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}last_id'])!,
    );
  }

  @override
  $SyncCursorsTable createAlias(String alias) {
    return $SyncCursorsTable(attachedDatabase, alias);
  }
}

class SyncCursor extends DataClass implements Insertable<SyncCursor> {
  final String entity;
  final int lastId;
  const SyncCursor({required this.entity, required this.lastId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['entity'] = Variable<String>(entity);
    map['last_id'] = Variable<int>(lastId);
    return map;
  }

  SyncCursorsCompanion toCompanion(bool nullToAbsent) {
    return SyncCursorsCompanion(
      entity: Value(entity),
      lastId: Value(lastId),
    );
  }

  factory SyncCursor.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncCursor(
      entity: serializer.fromJson<String>(json['entity']),
      lastId: serializer.fromJson<int>(json['lastId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'entity': serializer.toJson<String>(entity),
      'lastId': serializer.toJson<int>(lastId),
    };
  }

  SyncCursor copyWith({String? entity, int? lastId}) => SyncCursor(
        entity: entity ?? this.entity,
        lastId: lastId ?? this.lastId,
      );
  SyncCursor copyWithCompanion(SyncCursorsCompanion data) {
    return SyncCursor(
      entity: data.entity.present ? data.entity.value : this.entity,
      lastId: data.lastId.present ? data.lastId.value : this.lastId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursor(')
          ..write('entity: $entity, ')
          ..write('lastId: $lastId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(entity, lastId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncCursor &&
          other.entity == this.entity &&
          other.lastId == this.lastId);
}

class SyncCursorsCompanion extends UpdateCompanion<SyncCursor> {
  final Value<String> entity;
  final Value<int> lastId;
  final Value<int> rowid;
  const SyncCursorsCompanion({
    this.entity = const Value.absent(),
    this.lastId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncCursorsCompanion.insert({
    required String entity,
    this.lastId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : entity = Value(entity);
  static Insertable<SyncCursor> custom({
    Expression<String>? entity,
    Expression<int>? lastId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (entity != null) 'entity': entity,
      if (lastId != null) 'last_id': lastId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncCursorsCompanion copyWith(
      {Value<String>? entity, Value<int>? lastId, Value<int>? rowid}) {
    return SyncCursorsCompanion(
      entity: entity ?? this.entity,
      lastId: lastId ?? this.lastId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (entity.present) {
      map['entity'] = Variable<String>(entity.value);
    }
    if (lastId.present) {
      map['last_id'] = Variable<int>(lastId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncCursorsCompanion(')
          ..write('entity: $entity, ')
          ..write('lastId: $lastId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductsTable products = $ProductsTable(this);
  late final $SuppliersTable suppliers = $SuppliersTable(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $PurchasesTable purchases = $PurchasesTable(this);
  late final $PurchaseItemsTable purchaseItems = $PurchaseItemsTable(this);
  late final $SalesTable sales = $SalesTable(this);
  late final $SaleItemsTable saleItems = $SaleItemsTable(this);
  late final $StockMovementsTable stockMovements = $StockMovementsTable(this);
  late final $CashEntriesTable cashEntries = $CashEntriesTable(this);
  late final $GallonLedgerTable gallonLedger = $GallonLedgerTable(this);
  late final $CashierClosingsTable cashierClosings =
      $CashierClosingsTable(this);
  late final $SyncCursorsTable syncCursors = $SyncCursorsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        products,
        suppliers,
        customers,
        purchases,
        purchaseItems,
        sales,
        saleItems,
        stockMovements,
        cashEntries,
        gallonLedger,
        cashierClosings,
        syncCursors
      ];
}

typedef $$ProductsTableCreateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  required String name,
  Value<String> brand,
  Value<String> category,
  Value<String> baseUnit,
  Value<String?> packUnit,
  Value<int> packSize,
  Value<double> buyPrice,
  Value<double> sellPrice,
  Value<bool> isGallon,
  Value<bool> active,
});
typedef $$ProductsTableUpdateCompanionBuilder = ProductsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> brand,
  Value<String> category,
  Value<String> baseUnit,
  Value<String?> packUnit,
  Value<int> packSize,
  Value<double> buyPrice,
  Value<double> sellPrice,
  Value<bool> isGallon,
  Value<bool> active,
});

class $$ProductsTableFilterComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get baseUnit => $composableBuilder(
      column: $table.baseUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get packUnit => $composableBuilder(
      column: $table.packUnit, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get packSize => $composableBuilder(
      column: $table.packSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get buyPrice => $composableBuilder(
      column: $table.buyPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get sellPrice => $composableBuilder(
      column: $table.sellPrice, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isGallon => $composableBuilder(
      column: $table.isGallon, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnFilters(column));
}

class $$ProductsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get brand => $composableBuilder(
      column: $table.brand, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get baseUnit => $composableBuilder(
      column: $table.baseUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get packUnit => $composableBuilder(
      column: $table.packUnit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get packSize => $composableBuilder(
      column: $table.packSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get buyPrice => $composableBuilder(
      column: $table.buyPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get sellPrice => $composableBuilder(
      column: $table.sellPrice, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isGallon => $composableBuilder(
      column: $table.isGallon, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get active => $composableBuilder(
      column: $table.active, builder: (column) => ColumnOrderings(column));
}

class $$ProductsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductsTable> {
  $$ProductsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get brand =>
      $composableBuilder(column: $table.brand, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get baseUnit =>
      $composableBuilder(column: $table.baseUnit, builder: (column) => column);

  GeneratedColumn<String> get packUnit =>
      $composableBuilder(column: $table.packUnit, builder: (column) => column);

  GeneratedColumn<int> get packSize =>
      $composableBuilder(column: $table.packSize, builder: (column) => column);

  GeneratedColumn<double> get buyPrice =>
      $composableBuilder(column: $table.buyPrice, builder: (column) => column);

  GeneratedColumn<double> get sellPrice =>
      $composableBuilder(column: $table.sellPrice, builder: (column) => column);

  GeneratedColumn<bool> get isGallon =>
      $composableBuilder(column: $table.isGallon, builder: (column) => column);

  GeneratedColumn<bool> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$ProductsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()> {
  $$ProductsTableTableManager(_$AppDatabase db, $ProductsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> brand = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> baseUnit = const Value.absent(),
            Value<String?> packUnit = const Value.absent(),
            Value<int> packSize = const Value.absent(),
            Value<double> buyPrice = const Value.absent(),
            Value<double> sellPrice = const Value.absent(),
            Value<bool> isGallon = const Value.absent(),
            Value<bool> active = const Value.absent(),
          }) =>
              ProductsCompanion(
            id: id,
            name: name,
            brand: brand,
            category: category,
            baseUnit: baseUnit,
            packUnit: packUnit,
            packSize: packSize,
            buyPrice: buyPrice,
            sellPrice: sellPrice,
            isGallon: isGallon,
            active: active,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> brand = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> baseUnit = const Value.absent(),
            Value<String?> packUnit = const Value.absent(),
            Value<int> packSize = const Value.absent(),
            Value<double> buyPrice = const Value.absent(),
            Value<double> sellPrice = const Value.absent(),
            Value<bool> isGallon = const Value.absent(),
            Value<bool> active = const Value.absent(),
          }) =>
              ProductsCompanion.insert(
            id: id,
            name: name,
            brand: brand,
            category: category,
            baseUnit: baseUnit,
            packUnit: packUnit,
            packSize: packSize,
            buyPrice: buyPrice,
            sellPrice: sellPrice,
            isGallon: isGallon,
            active: active,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ProductsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ProductsTable,
    Product,
    $$ProductsTableFilterComposer,
    $$ProductsTableOrderingComposer,
    $$ProductsTableAnnotationComposer,
    $$ProductsTableCreateCompanionBuilder,
    $$ProductsTableUpdateCompanionBuilder,
    (Product, BaseReferences<_$AppDatabase, $ProductsTable, Product>),
    Product,
    PrefetchHooks Function()>;
typedef $$SuppliersTableCreateCompanionBuilder = SuppliersCompanion Function({
  Value<int> id,
  required String name,
  Value<String?> phone,
  Value<String?> note,
});
typedef $$SuppliersTableUpdateCompanionBuilder = SuppliersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String?> phone,
  Value<String?> note,
});

class $$SuppliersTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$SuppliersTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$SuppliersTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTable> {
  $$SuppliersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$SuppliersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SuppliersTable,
    Supplier,
    $$SuppliersTableFilterComposer,
    $$SuppliersTableOrderingComposer,
    $$SuppliersTableAnnotationComposer,
    $$SuppliersTableCreateCompanionBuilder,
    $$SuppliersTableUpdateCompanionBuilder,
    (Supplier, BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>),
    Supplier,
    PrefetchHooks Function()> {
  $$SuppliersTableTableManager(_$AppDatabase db, $SuppliersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String?> phone = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              SuppliersCompanion(
            id: id,
            name: name,
            phone: phone,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String?> phone = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              SuppliersCompanion.insert(
            id: id,
            name: name,
            phone: phone,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SuppliersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SuppliersTable,
    Supplier,
    $$SuppliersTableFilterComposer,
    $$SuppliersTableOrderingComposer,
    $$SuppliersTableAnnotationComposer,
    $$SuppliersTableCreateCompanionBuilder,
    $$SuppliersTableUpdateCompanionBuilder,
    (Supplier, BaseReferences<_$AppDatabase, $SuppliersTable, Supplier>),
    Supplier,
    PrefetchHooks Function()>;
typedef $$CustomersTableCreateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  required String name,
  Value<String> type,
  Value<String?> phone,
});
typedef $$CustomersTableUpdateCompanionBuilder = CustomersCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> type,
  Value<String?> phone,
});

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnFilters(column));
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get phone => $composableBuilder(
      column: $table.phone, builder: (column) => ColumnOrderings(column));
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);
}

class $$CustomersTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
    Customer,
    PrefetchHooks Function()> {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<String?> phone = const Value.absent(),
          }) =>
              CustomersCompanion(
            id: id,
            name: name,
            type: type,
            phone: phone,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<String> type = const Value.absent(),
            Value<String?> phone = const Value.absent(),
          }) =>
              CustomersCompanion.insert(
            id: id,
            name: name,
            type: type,
            phone: phone,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CustomersTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CustomersTable,
    Customer,
    $$CustomersTableFilterComposer,
    $$CustomersTableOrderingComposer,
    $$CustomersTableAnnotationComposer,
    $$CustomersTableCreateCompanionBuilder,
    $$CustomersTableUpdateCompanionBuilder,
    (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
    Customer,
    PrefetchHooks Function()>;
typedef $$PurchasesTableCreateCompanionBuilder = PurchasesCompanion Function({
  Value<int> id,
  Value<int?> supplierId,
  Value<DateTime> date,
  Value<double> totalAmount,
  Value<String> paymentStatus,
  Value<String?> note,
});
typedef $$PurchasesTableUpdateCompanionBuilder = PurchasesCompanion Function({
  Value<int> id,
  Value<int?> supplierId,
  Value<DateTime> date,
  Value<double> totalAmount,
  Value<String> paymentStatus,
  Value<String?> note,
});

class $$PurchasesTableFilterComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$PurchasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$PurchasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchasesTable> {
  $$PurchasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get supplierId => $composableBuilder(
      column: $table.supplierId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$PurchasesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PurchasesTable,
    Purchase,
    $$PurchasesTableFilterComposer,
    $$PurchasesTableOrderingComposer,
    $$PurchasesTableAnnotationComposer,
    $$PurchasesTableCreateCompanionBuilder,
    $$PurchasesTableUpdateCompanionBuilder,
    (Purchase, BaseReferences<_$AppDatabase, $PurchasesTable, Purchase>),
    Purchase,
    PrefetchHooks Function()> {
  $$PurchasesTableTableManager(_$AppDatabase db, $PurchasesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> supplierId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              PurchasesCompanion(
            id: id,
            supplierId: supplierId,
            date: date,
            totalAmount: totalAmount,
            paymentStatus: paymentStatus,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> supplierId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              PurchasesCompanion.insert(
            id: id,
            supplierId: supplierId,
            date: date,
            totalAmount: totalAmount,
            paymentStatus: paymentStatus,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PurchasesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PurchasesTable,
    Purchase,
    $$PurchasesTableFilterComposer,
    $$PurchasesTableOrderingComposer,
    $$PurchasesTableAnnotationComposer,
    $$PurchasesTableCreateCompanionBuilder,
    $$PurchasesTableUpdateCompanionBuilder,
    (Purchase, BaseReferences<_$AppDatabase, $PurchasesTable, Purchase>),
    Purchase,
    PrefetchHooks Function()>;
typedef $$PurchaseItemsTableCreateCompanionBuilder = PurchaseItemsCompanion
    Function({
  Value<int> id,
  required int purchaseId,
  required int productId,
  required int qtyBase,
  required double price,
  required double subtotal,
});
typedef $$PurchaseItemsTableUpdateCompanionBuilder = PurchaseItemsCompanion
    Function({
  Value<int> id,
  Value<int> purchaseId,
  Value<int> productId,
  Value<int> qtyBase,
  Value<double> price,
  Value<double> subtotal,
});

class $$PurchaseItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtyBase => $composableBuilder(
      column: $table.qtyBase, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));
}

class $$PurchaseItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtyBase => $composableBuilder(
      column: $table.qtyBase, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));
}

class $$PurchaseItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PurchaseItemsTable> {
  $$PurchaseItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get purchaseId => $composableBuilder(
      column: $table.purchaseId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get qtyBase =>
      $composableBuilder(column: $table.qtyBase, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);
}

class $$PurchaseItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $PurchaseItemsTable,
    PurchaseItem,
    $$PurchaseItemsTableFilterComposer,
    $$PurchaseItemsTableOrderingComposer,
    $$PurchaseItemsTableAnnotationComposer,
    $$PurchaseItemsTableCreateCompanionBuilder,
    $$PurchaseItemsTableUpdateCompanionBuilder,
    (
      PurchaseItem,
      BaseReferences<_$AppDatabase, $PurchaseItemsTable, PurchaseItem>
    ),
    PurchaseItem,
    PrefetchHooks Function()> {
  $$PurchaseItemsTableTableManager(_$AppDatabase db, $PurchaseItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PurchaseItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PurchaseItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PurchaseItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> purchaseId = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<int> qtyBase = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
          }) =>
              PurchaseItemsCompanion(
            id: id,
            purchaseId: purchaseId,
            productId: productId,
            qtyBase: qtyBase,
            price: price,
            subtotal: subtotal,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int purchaseId,
            required int productId,
            required int qtyBase,
            required double price,
            required double subtotal,
          }) =>
              PurchaseItemsCompanion.insert(
            id: id,
            purchaseId: purchaseId,
            productId: productId,
            qtyBase: qtyBase,
            price: price,
            subtotal: subtotal,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$PurchaseItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $PurchaseItemsTable,
    PurchaseItem,
    $$PurchaseItemsTableFilterComposer,
    $$PurchaseItemsTableOrderingComposer,
    $$PurchaseItemsTableAnnotationComposer,
    $$PurchaseItemsTableCreateCompanionBuilder,
    $$PurchaseItemsTableUpdateCompanionBuilder,
    (
      PurchaseItem,
      BaseReferences<_$AppDatabase, $PurchaseItemsTable, PurchaseItem>
    ),
    PurchaseItem,
    PrefetchHooks Function()>;
typedef $$SalesTableCreateCompanionBuilder = SalesCompanion Function({
  Value<int> id,
  Value<int?> customerId,
  Value<DateTime> date,
  Value<double> totalAmount,
  Value<String> paymentMethod,
  Value<String> paymentStatus,
  Value<String?> note,
});
typedef $$SalesTableUpdateCompanionBuilder = SalesCompanion Function({
  Value<int> id,
  Value<int?> customerId,
  Value<DateTime> date,
  Value<double> totalAmount,
  Value<String> paymentMethod,
  Value<String> paymentStatus,
  Value<String?> note,
});

class $$SalesTableFilterComposer extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$SalesTableOrderingComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$SalesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SalesTable> {
  $$SalesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get totalAmount => $composableBuilder(
      column: $table.totalAmount, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
      column: $table.paymentStatus, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$SalesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SalesTable,
    Sale,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
    Sale,
    PrefetchHooks Function()> {
  $$SalesTableTableManager(_$AppDatabase db, $SalesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SalesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SalesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SalesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> customerId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              SalesCompanion(
            id: id,
            customerId: customerId,
            date: date,
            totalAmount: totalAmount,
            paymentMethod: paymentMethod,
            paymentStatus: paymentStatus,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int?> customerId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> totalAmount = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<String> paymentStatus = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              SalesCompanion.insert(
            id: id,
            customerId: customerId,
            date: date,
            totalAmount: totalAmount,
            paymentMethod: paymentMethod,
            paymentStatus: paymentStatus,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SalesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SalesTable,
    Sale,
    $$SalesTableFilterComposer,
    $$SalesTableOrderingComposer,
    $$SalesTableAnnotationComposer,
    $$SalesTableCreateCompanionBuilder,
    $$SalesTableUpdateCompanionBuilder,
    (Sale, BaseReferences<_$AppDatabase, $SalesTable, Sale>),
    Sale,
    PrefetchHooks Function()>;
typedef $$SaleItemsTableCreateCompanionBuilder = SaleItemsCompanion Function({
  Value<int> id,
  required int saleId,
  required int productId,
  required int qtyBase,
  required double price,
  required double subtotal,
});
typedef $$SaleItemsTableUpdateCompanionBuilder = SaleItemsCompanion Function({
  Value<int> id,
  Value<int> saleId,
  Value<int> productId,
  Value<int> qtyBase,
  Value<double> price,
  Value<double> subtotal,
});

class $$SaleItemsTableFilterComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtyBase => $composableBuilder(
      column: $table.qtyBase, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnFilters(column));
}

class $$SaleItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get saleId => $composableBuilder(
      column: $table.saleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtyBase => $composableBuilder(
      column: $table.qtyBase, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get price => $composableBuilder(
      column: $table.price, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get subtotal => $composableBuilder(
      column: $table.subtotal, builder: (column) => ColumnOrderings(column));
}

class $$SaleItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SaleItemsTable> {
  $$SaleItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get saleId =>
      $composableBuilder(column: $table.saleId, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<int> get qtyBase =>
      $composableBuilder(column: $table.qtyBase, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);
}

class $$SaleItemsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SaleItemsTable,
    SaleItem,
    $$SaleItemsTableFilterComposer,
    $$SaleItemsTableOrderingComposer,
    $$SaleItemsTableAnnotationComposer,
    $$SaleItemsTableCreateCompanionBuilder,
    $$SaleItemsTableUpdateCompanionBuilder,
    (SaleItem, BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItem>),
    SaleItem,
    PrefetchHooks Function()> {
  $$SaleItemsTableTableManager(_$AppDatabase db, $SaleItemsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SaleItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SaleItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SaleItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> saleId = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<int> qtyBase = const Value.absent(),
            Value<double> price = const Value.absent(),
            Value<double> subtotal = const Value.absent(),
          }) =>
              SaleItemsCompanion(
            id: id,
            saleId: saleId,
            productId: productId,
            qtyBase: qtyBase,
            price: price,
            subtotal: subtotal,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int saleId,
            required int productId,
            required int qtyBase,
            required double price,
            required double subtotal,
          }) =>
              SaleItemsCompanion.insert(
            id: id,
            saleId: saleId,
            productId: productId,
            qtyBase: qtyBase,
            price: price,
            subtotal: subtotal,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SaleItemsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SaleItemsTable,
    SaleItem,
    $$SaleItemsTableFilterComposer,
    $$SaleItemsTableOrderingComposer,
    $$SaleItemsTableAnnotationComposer,
    $$SaleItemsTableCreateCompanionBuilder,
    $$SaleItemsTableUpdateCompanionBuilder,
    (SaleItem, BaseReferences<_$AppDatabase, $SaleItemsTable, SaleItem>),
    SaleItem,
    PrefetchHooks Function()>;
typedef $$StockMovementsTableCreateCompanionBuilder = StockMovementsCompanion
    Function({
  Value<int> id,
  required int productId,
  Value<DateTime> date,
  required String type,
  required int qtyBase,
  Value<String?> refType,
  Value<int?> refId,
  Value<String?> note,
});
typedef $$StockMovementsTableUpdateCompanionBuilder = StockMovementsCompanion
    Function({
  Value<int> id,
  Value<int> productId,
  Value<DateTime> date,
  Value<String> type,
  Value<int> qtyBase,
  Value<String?> refType,
  Value<int?> refId,
  Value<String?> note,
});

class $$StockMovementsTableFilterComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get qtyBase => $composableBuilder(
      column: $table.qtyBase, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refType => $composableBuilder(
      column: $table.refType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get refId => $composableBuilder(
      column: $table.refId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$StockMovementsTableOrderingComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get productId => $composableBuilder(
      column: $table.productId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get qtyBase => $composableBuilder(
      column: $table.qtyBase, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refType => $composableBuilder(
      column: $table.refType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get refId => $composableBuilder(
      column: $table.refId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$StockMovementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $StockMovementsTable> {
  $$StockMovementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get productId =>
      $composableBuilder(column: $table.productId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get qtyBase =>
      $composableBuilder(column: $table.qtyBase, builder: (column) => column);

  GeneratedColumn<String> get refType =>
      $composableBuilder(column: $table.refType, builder: (column) => column);

  GeneratedColumn<int> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$StockMovementsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovement,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (
      StockMovement,
      BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>
    ),
    StockMovement,
    PrefetchHooks Function()> {
  $$StockMovementsTableTableManager(
      _$AppDatabase db, $StockMovementsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StockMovementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StockMovementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StockMovementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<int> productId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> qtyBase = const Value.absent(),
            Value<String?> refType = const Value.absent(),
            Value<int?> refId = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              StockMovementsCompanion(
            id: id,
            productId: productId,
            date: date,
            type: type,
            qtyBase: qtyBase,
            refType: refType,
            refId: refId,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required int productId,
            Value<DateTime> date = const Value.absent(),
            required String type,
            required int qtyBase,
            Value<String?> refType = const Value.absent(),
            Value<int?> refId = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              StockMovementsCompanion.insert(
            id: id,
            productId: productId,
            date: date,
            type: type,
            qtyBase: qtyBase,
            refType: refType,
            refId: refId,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$StockMovementsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $StockMovementsTable,
    StockMovement,
    $$StockMovementsTableFilterComposer,
    $$StockMovementsTableOrderingComposer,
    $$StockMovementsTableAnnotationComposer,
    $$StockMovementsTableCreateCompanionBuilder,
    $$StockMovementsTableUpdateCompanionBuilder,
    (
      StockMovement,
      BaseReferences<_$AppDatabase, $StockMovementsTable, StockMovement>
    ),
    StockMovement,
    PrefetchHooks Function()>;
typedef $$CashEntriesTableCreateCompanionBuilder = CashEntriesCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  required String direction,
  required double amount,
  required String category,
  Value<String> account,
  Value<String?> refType,
  Value<int?> refId,
  Value<String?> note,
});
typedef $$CashEntriesTableUpdateCompanionBuilder = CashEntriesCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> direction,
  Value<double> amount,
  Value<String> category,
  Value<String> account,
  Value<String?> refType,
  Value<int?> refId,
  Value<String?> note,
});

class $$CashEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CashEntriesTable> {
  $$CashEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get account => $composableBuilder(
      column: $table.account, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refType => $composableBuilder(
      column: $table.refType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get refId => $composableBuilder(
      column: $table.refId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$CashEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CashEntriesTable> {
  $$CashEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get direction => $composableBuilder(
      column: $table.direction, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get account => $composableBuilder(
      column: $table.account, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refType => $composableBuilder(
      column: $table.refType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get refId => $composableBuilder(
      column: $table.refId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$CashEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashEntriesTable> {
  $$CashEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get direction =>
      $composableBuilder(column: $table.direction, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<String> get refType =>
      $composableBuilder(column: $table.refType, builder: (column) => column);

  GeneratedColumn<int> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$CashEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CashEntriesTable,
    CashEntry,
    $$CashEntriesTableFilterComposer,
    $$CashEntriesTableOrderingComposer,
    $$CashEntriesTableAnnotationComposer,
    $$CashEntriesTableCreateCompanionBuilder,
    $$CashEntriesTableUpdateCompanionBuilder,
    (CashEntry, BaseReferences<_$AppDatabase, $CashEntriesTable, CashEntry>),
    CashEntry,
    PrefetchHooks Function()> {
  $$CashEntriesTableTableManager(_$AppDatabase db, $CashEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> direction = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> account = const Value.absent(),
            Value<String?> refType = const Value.absent(),
            Value<int?> refId = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              CashEntriesCompanion(
            id: id,
            date: date,
            direction: direction,
            amount: amount,
            category: category,
            account: account,
            refType: refType,
            refId: refId,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            required String direction,
            required double amount,
            required String category,
            Value<String> account = const Value.absent(),
            Value<String?> refType = const Value.absent(),
            Value<int?> refId = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              CashEntriesCompanion.insert(
            id: id,
            date: date,
            direction: direction,
            amount: amount,
            category: category,
            account: account,
            refType: refType,
            refId: refId,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CashEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CashEntriesTable,
    CashEntry,
    $$CashEntriesTableFilterComposer,
    $$CashEntriesTableOrderingComposer,
    $$CashEntriesTableAnnotationComposer,
    $$CashEntriesTableCreateCompanionBuilder,
    $$CashEntriesTableUpdateCompanionBuilder,
    (CashEntry, BaseReferences<_$AppDatabase, $CashEntriesTable, CashEntry>),
    CashEntry,
    PrefetchHooks Function()>;
typedef $$GallonLedgerTableCreateCompanionBuilder = GallonLedgerCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  required String type,
  Value<int> dFull,
  Value<int> dEmpty,
  Value<int> dDeposit,
  Value<int?> customerId,
  Value<String?> refType,
  Value<int?> refId,
  Value<String?> note,
});
typedef $$GallonLedgerTableUpdateCompanionBuilder = GallonLedgerCompanion
    Function({
  Value<int> id,
  Value<DateTime> date,
  Value<String> type,
  Value<int> dFull,
  Value<int> dEmpty,
  Value<int> dDeposit,
  Value<int?> customerId,
  Value<String?> refType,
  Value<int?> refId,
  Value<String?> note,
});

class $$GallonLedgerTableFilterComposer
    extends Composer<_$AppDatabase, $GallonLedgerTable> {
  $$GallonLedgerTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dFull => $composableBuilder(
      column: $table.dFull, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dEmpty => $composableBuilder(
      column: $table.dEmpty, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get dDeposit => $composableBuilder(
      column: $table.dDeposit, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get refType => $composableBuilder(
      column: $table.refType, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get refId => $composableBuilder(
      column: $table.refId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$GallonLedgerTableOrderingComposer
    extends Composer<_$AppDatabase, $GallonLedgerTable> {
  $$GallonLedgerTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get type => $composableBuilder(
      column: $table.type, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dFull => $composableBuilder(
      column: $table.dFull, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dEmpty => $composableBuilder(
      column: $table.dEmpty, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get dDeposit => $composableBuilder(
      column: $table.dDeposit, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get refType => $composableBuilder(
      column: $table.refType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get refId => $composableBuilder(
      column: $table.refId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$GallonLedgerTableAnnotationComposer
    extends Composer<_$AppDatabase, $GallonLedgerTable> {
  $$GallonLedgerTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get dFull =>
      $composableBuilder(column: $table.dFull, builder: (column) => column);

  GeneratedColumn<int> get dEmpty =>
      $composableBuilder(column: $table.dEmpty, builder: (column) => column);

  GeneratedColumn<int> get dDeposit =>
      $composableBuilder(column: $table.dDeposit, builder: (column) => column);

  GeneratedColumn<int> get customerId => $composableBuilder(
      column: $table.customerId, builder: (column) => column);

  GeneratedColumn<String> get refType =>
      $composableBuilder(column: $table.refType, builder: (column) => column);

  GeneratedColumn<int> get refId =>
      $composableBuilder(column: $table.refId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$GallonLedgerTableTableManager extends RootTableManager<
    _$AppDatabase,
    $GallonLedgerTable,
    GallonLedgerData,
    $$GallonLedgerTableFilterComposer,
    $$GallonLedgerTableOrderingComposer,
    $$GallonLedgerTableAnnotationComposer,
    $$GallonLedgerTableCreateCompanionBuilder,
    $$GallonLedgerTableUpdateCompanionBuilder,
    (
      GallonLedgerData,
      BaseReferences<_$AppDatabase, $GallonLedgerTable, GallonLedgerData>
    ),
    GallonLedgerData,
    PrefetchHooks Function()> {
  $$GallonLedgerTableTableManager(_$AppDatabase db, $GallonLedgerTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GallonLedgerTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GallonLedgerTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GallonLedgerTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> type = const Value.absent(),
            Value<int> dFull = const Value.absent(),
            Value<int> dEmpty = const Value.absent(),
            Value<int> dDeposit = const Value.absent(),
            Value<int?> customerId = const Value.absent(),
            Value<String?> refType = const Value.absent(),
            Value<int?> refId = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              GallonLedgerCompanion(
            id: id,
            date: date,
            type: type,
            dFull: dFull,
            dEmpty: dEmpty,
            dDeposit: dDeposit,
            customerId: customerId,
            refType: refType,
            refId: refId,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            required String type,
            Value<int> dFull = const Value.absent(),
            Value<int> dEmpty = const Value.absent(),
            Value<int> dDeposit = const Value.absent(),
            Value<int?> customerId = const Value.absent(),
            Value<String?> refType = const Value.absent(),
            Value<int?> refId = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              GallonLedgerCompanion.insert(
            id: id,
            date: date,
            type: type,
            dFull: dFull,
            dEmpty: dEmpty,
            dDeposit: dDeposit,
            customerId: customerId,
            refType: refType,
            refId: refId,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$GallonLedgerTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $GallonLedgerTable,
    GallonLedgerData,
    $$GallonLedgerTableFilterComposer,
    $$GallonLedgerTableOrderingComposer,
    $$GallonLedgerTableAnnotationComposer,
    $$GallonLedgerTableCreateCompanionBuilder,
    $$GallonLedgerTableUpdateCompanionBuilder,
    (
      GallonLedgerData,
      BaseReferences<_$AppDatabase, $GallonLedgerTable, GallonLedgerData>
    ),
    GallonLedgerData,
    PrefetchHooks Function()>;
typedef $$CashierClosingsTableCreateCompanionBuilder = CashierClosingsCompanion
    Function({
  Value<int> id,
  Value<DateTime> closedAt,
  Value<String> account,
  required double systemBalance,
  required double physicalCount,
  required double difference,
  Value<String?> note,
});
typedef $$CashierClosingsTableUpdateCompanionBuilder = CashierClosingsCompanion
    Function({
  Value<int> id,
  Value<DateTime> closedAt,
  Value<String> account,
  Value<double> systemBalance,
  Value<double> physicalCount,
  Value<double> difference,
  Value<String?> note,
});

class $$CashierClosingsTableFilterComposer
    extends Composer<_$AppDatabase, $CashierClosingsTable> {
  $$CashierClosingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get account => $composableBuilder(
      column: $table.account, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get systemBalance => $composableBuilder(
      column: $table.systemBalance, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get physicalCount => $composableBuilder(
      column: $table.physicalCount, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get difference => $composableBuilder(
      column: $table.difference, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$CashierClosingsTableOrderingComposer
    extends Composer<_$AppDatabase, $CashierClosingsTable> {
  $$CashierClosingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
      column: $table.closedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get account => $composableBuilder(
      column: $table.account, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get systemBalance => $composableBuilder(
      column: $table.systemBalance,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get physicalCount => $composableBuilder(
      column: $table.physicalCount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get difference => $composableBuilder(
      column: $table.difference, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$CashierClosingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $CashierClosingsTable> {
  $$CashierClosingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);

  GeneratedColumn<String> get account =>
      $composableBuilder(column: $table.account, builder: (column) => column);

  GeneratedColumn<double> get systemBalance => $composableBuilder(
      column: $table.systemBalance, builder: (column) => column);

  GeneratedColumn<double> get physicalCount => $composableBuilder(
      column: $table.physicalCount, builder: (column) => column);

  GeneratedColumn<double> get difference => $composableBuilder(
      column: $table.difference, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$CashierClosingsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CashierClosingsTable,
    CashierClosing,
    $$CashierClosingsTableFilterComposer,
    $$CashierClosingsTableOrderingComposer,
    $$CashierClosingsTableAnnotationComposer,
    $$CashierClosingsTableCreateCompanionBuilder,
    $$CashierClosingsTableUpdateCompanionBuilder,
    (
      CashierClosing,
      BaseReferences<_$AppDatabase, $CashierClosingsTable, CashierClosing>
    ),
    CashierClosing,
    PrefetchHooks Function()> {
  $$CashierClosingsTableTableManager(
      _$AppDatabase db, $CashierClosingsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CashierClosingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CashierClosingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CashierClosingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> closedAt = const Value.absent(),
            Value<String> account = const Value.absent(),
            Value<double> systemBalance = const Value.absent(),
            Value<double> physicalCount = const Value.absent(),
            Value<double> difference = const Value.absent(),
            Value<String?> note = const Value.absent(),
          }) =>
              CashierClosingsCompanion(
            id: id,
            closedAt: closedAt,
            account: account,
            systemBalance: systemBalance,
            physicalCount: physicalCount,
            difference: difference,
            note: note,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<DateTime> closedAt = const Value.absent(),
            Value<String> account = const Value.absent(),
            required double systemBalance,
            required double physicalCount,
            required double difference,
            Value<String?> note = const Value.absent(),
          }) =>
              CashierClosingsCompanion.insert(
            id: id,
            closedAt: closedAt,
            account: account,
            systemBalance: systemBalance,
            physicalCount: physicalCount,
            difference: difference,
            note: note,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$CashierClosingsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CashierClosingsTable,
    CashierClosing,
    $$CashierClosingsTableFilterComposer,
    $$CashierClosingsTableOrderingComposer,
    $$CashierClosingsTableAnnotationComposer,
    $$CashierClosingsTableCreateCompanionBuilder,
    $$CashierClosingsTableUpdateCompanionBuilder,
    (
      CashierClosing,
      BaseReferences<_$AppDatabase, $CashierClosingsTable, CashierClosing>
    ),
    CashierClosing,
    PrefetchHooks Function()>;
typedef $$SyncCursorsTableCreateCompanionBuilder = SyncCursorsCompanion
    Function({
  required String entity,
  Value<int> lastId,
  Value<int> rowid,
});
typedef $$SyncCursorsTableUpdateCompanionBuilder = SyncCursorsCompanion
    Function({
  Value<String> entity,
  Value<int> lastId,
  Value<int> rowid,
});

class $$SyncCursorsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get lastId => $composableBuilder(
      column: $table.lastId, builder: (column) => ColumnFilters(column));
}

class $$SyncCursorsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get entity => $composableBuilder(
      column: $table.entity, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get lastId => $composableBuilder(
      column: $table.lastId, builder: (column) => ColumnOrderings(column));
}

class $$SyncCursorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncCursorsTable> {
  $$SyncCursorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get entity =>
      $composableBuilder(column: $table.entity, builder: (column) => column);

  GeneratedColumn<int> get lastId =>
      $composableBuilder(column: $table.lastId, builder: (column) => column);
}

class $$SyncCursorsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SyncCursorsTable,
    SyncCursor,
    $$SyncCursorsTableFilterComposer,
    $$SyncCursorsTableOrderingComposer,
    $$SyncCursorsTableAnnotationComposer,
    $$SyncCursorsTableCreateCompanionBuilder,
    $$SyncCursorsTableUpdateCompanionBuilder,
    (SyncCursor, BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>),
    SyncCursor,
    PrefetchHooks Function()> {
  $$SyncCursorsTableTableManager(_$AppDatabase db, $SyncCursorsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncCursorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncCursorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncCursorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> entity = const Value.absent(),
            Value<int> lastId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncCursorsCompanion(
            entity: entity,
            lastId: lastId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String entity,
            Value<int> lastId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SyncCursorsCompanion.insert(
            entity: entity,
            lastId: lastId,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SyncCursorsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SyncCursorsTable,
    SyncCursor,
    $$SyncCursorsTableFilterComposer,
    $$SyncCursorsTableOrderingComposer,
    $$SyncCursorsTableAnnotationComposer,
    $$SyncCursorsTableCreateCompanionBuilder,
    $$SyncCursorsTableUpdateCompanionBuilder,
    (SyncCursor, BaseReferences<_$AppDatabase, $SyncCursorsTable, SyncCursor>),
    SyncCursor,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductsTableTableManager get products =>
      $$ProductsTableTableManager(_db, _db.products);
  $$SuppliersTableTableManager get suppliers =>
      $$SuppliersTableTableManager(_db, _db.suppliers);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$PurchasesTableTableManager get purchases =>
      $$PurchasesTableTableManager(_db, _db.purchases);
  $$PurchaseItemsTableTableManager get purchaseItems =>
      $$PurchaseItemsTableTableManager(_db, _db.purchaseItems);
  $$SalesTableTableManager get sales =>
      $$SalesTableTableManager(_db, _db.sales);
  $$SaleItemsTableTableManager get saleItems =>
      $$SaleItemsTableTableManager(_db, _db.saleItems);
  $$StockMovementsTableTableManager get stockMovements =>
      $$StockMovementsTableTableManager(_db, _db.stockMovements);
  $$CashEntriesTableTableManager get cashEntries =>
      $$CashEntriesTableTableManager(_db, _db.cashEntries);
  $$GallonLedgerTableTableManager get gallonLedger =>
      $$GallonLedgerTableTableManager(_db, _db.gallonLedger);
  $$CashierClosingsTableTableManager get cashierClosings =>
      $$CashierClosingsTableTableManager(_db, _db.cashierClosings);
  $$SyncCursorsTableTableManager get syncCursors =>
      $$SyncCursorsTableTableManager(_db, _db.syncCursors);
}
