// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BooksTable extends Books with TableInfo<$BooksTable, BookRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BooksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourcePdfPathMeta = const VerificationMeta(
    'sourcePdfPath',
  );
  @override
  late final GeneratedColumn<String> sourcePdfPath = GeneratedColumn<String>(
    'source_pdf_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverMeta = const VerificationMeta('cover');
  @override
  late final GeneratedColumn<Uint8List> cover = GeneratedColumn<Uint8List>(
    'cover',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    sourcePdfPath,
    cover,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'books';
  @override
  VerificationContext validateIntegrity(
    Insertable<BookRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('source_pdf_path')) {
      context.handle(
        _sourcePdfPathMeta,
        sourcePdfPath.isAcceptableOrUnknown(
          data['source_pdf_path']!,
          _sourcePdfPathMeta,
        ),
      );
    }
    if (data.containsKey('cover')) {
      context.handle(
        _coverMeta,
        cover.isAcceptableOrUnknown(data['cover']!, _coverMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BookRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BookRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      sourcePdfPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_pdf_path'],
      ),
      cover: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}cover'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BooksTable createAlias(String alias) {
    return $BooksTable(attachedDatabase, alias);
  }
}

class BookRow extends DataClass implements Insertable<BookRow> {
  final int id;
  final String title;

  /// Путь к исходному PDF книги.
  final String? sourcePdfPath;

  /// PNG-обложка (первая выбранная страница; она НЕ обрабатывается CV и
  /// не входит в страницы книги — только превью для карточки галереи).
  final Uint8List? cover;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BookRow({
    required this.id,
    required this.title,
    this.sourcePdfPath,
    this.cover,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || sourcePdfPath != null) {
      map['source_pdf_path'] = Variable<String>(sourcePdfPath);
    }
    if (!nullToAbsent || cover != null) {
      map['cover'] = Variable<Uint8List>(cover);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BooksCompanion toCompanion(bool nullToAbsent) {
    return BooksCompanion(
      id: Value(id),
      title: Value(title),
      sourcePdfPath: sourcePdfPath == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePdfPath),
      cover: cover == null && nullToAbsent
          ? const Value.absent()
          : Value(cover),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BookRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BookRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      sourcePdfPath: serializer.fromJson<String?>(json['sourcePdfPath']),
      cover: serializer.fromJson<Uint8List?>(json['cover']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'sourcePdfPath': serializer.toJson<String?>(sourcePdfPath),
      'cover': serializer.toJson<Uint8List?>(cover),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BookRow copyWith({
    int? id,
    String? title,
    Value<String?> sourcePdfPath = const Value.absent(),
    Value<Uint8List?> cover = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BookRow(
    id: id ?? this.id,
    title: title ?? this.title,
    sourcePdfPath: sourcePdfPath.present
        ? sourcePdfPath.value
        : this.sourcePdfPath,
    cover: cover.present ? cover.value : this.cover,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BookRow copyWithCompanion(BooksCompanion data) {
    return BookRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      sourcePdfPath: data.sourcePdfPath.present
          ? data.sourcePdfPath.value
          : this.sourcePdfPath,
      cover: data.cover.present ? data.cover.value : this.cover,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BookRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sourcePdfPath: $sourcePdfPath, ')
          ..write('cover: $cover, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    sourcePdfPath,
    $driftBlobEquality.hash(cover),
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BookRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.sourcePdfPath == this.sourcePdfPath &&
          $driftBlobEquality.equals(other.cover, this.cover) &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BooksCompanion extends UpdateCompanion<BookRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<String?> sourcePdfPath;
  final Value<Uint8List?> cover;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const BooksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.sourcePdfPath = const Value.absent(),
    this.cover = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  BooksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.sourcePdfPath = const Value.absent(),
    this.cover = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<BookRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? sourcePdfPath,
    Expression<Uint8List>? cover,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (sourcePdfPath != null) 'source_pdf_path': sourcePdfPath,
      if (cover != null) 'cover': cover,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  BooksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String?>? sourcePdfPath,
    Value<Uint8List?>? cover,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return BooksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      sourcePdfPath: sourcePdfPath ?? this.sourcePdfPath,
      cover: cover ?? this.cover,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (sourcePdfPath.present) {
      map['source_pdf_path'] = Variable<String>(sourcePdfPath.value);
    }
    if (cover.present) {
      map['cover'] = Variable<Uint8List>(cover.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BooksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('sourcePdfPath: $sourcePdfPath, ')
          ..write('cover: $cover, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $ArtworksTable extends Artworks
    with TableInfo<$ArtworksTable, ArtworkRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ArtworksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    additionalChecks: GeneratedColumn.checkTextLength(
      minTextLength: 1,
      maxTextLength: 120,
    ),
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bookIdMeta = const VerificationMeta('bookId');
  @override
  late final GeneratedColumn<int> bookId = GeneratedColumn<int>(
    'book_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES books (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<int> status = GeneratedColumn<int>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _progressMeta = const VerificationMeta(
    'progress',
  );
  @override
  late final GeneratedColumn<double> progress = GeneratedColumn<double>(
    'progress',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _thumbnailMeta = const VerificationMeta(
    'thumbnail',
  );
  @override
  late final GeneratedColumn<Uint8List> thumbnail = GeneratedColumn<Uint8List>(
    'thumbnail',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourcePdfPathMeta = const VerificationMeta(
    'sourcePdfPath',
  );
  @override
  late final GeneratedColumn<String> sourcePdfPath = GeneratedColumn<String>(
    'source_pdf_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pageIndexMeta = const VerificationMeta(
    'pageIndex',
  );
  @override
  late final GeneratedColumn<int> pageIndex = GeneratedColumn<int>(
    'page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    bookId,
    status,
    progress,
    thumbnail,
    sourcePdfPath,
    pageIndex,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'artworks';
  @override
  VerificationContext validateIntegrity(
    Insertable<ArtworkRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('book_id')) {
      context.handle(
        _bookIdMeta,
        bookId.isAcceptableOrUnknown(data['book_id']!, _bookIdMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('progress')) {
      context.handle(
        _progressMeta,
        progress.isAcceptableOrUnknown(data['progress']!, _progressMeta),
      );
    }
    if (data.containsKey('thumbnail')) {
      context.handle(
        _thumbnailMeta,
        thumbnail.isAcceptableOrUnknown(data['thumbnail']!, _thumbnailMeta),
      );
    }
    if (data.containsKey('source_pdf_path')) {
      context.handle(
        _sourcePdfPathMeta,
        sourcePdfPath.isAcceptableOrUnknown(
          data['source_pdf_path']!,
          _sourcePdfPathMeta,
        ),
      );
    }
    if (data.containsKey('page_index')) {
      context.handle(
        _pageIndexMeta,
        pageIndex.isAcceptableOrUnknown(data['page_index']!, _pageIndexMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ArtworkRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ArtworkRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      bookId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}book_id'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}status'],
      )!,
      progress: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}progress'],
      )!,
      thumbnail: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}thumbnail'],
      ),
      sourcePdfPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_pdf_path'],
      ),
      pageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}page_index'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ArtworksTable createAlias(String alias) {
    return $ArtworksTable(attachedDatabase, alias);
  }
}

class ArtworkRow extends DataClass implements Insertable<ArtworkRow> {
  final int id;
  final String title;

  /// Книга, к которой относится страница (null — одиночная работа).
  final int? bookId;

  /// Индекс значения enum ArtworkStatus (new / inProgress / done).
  final int status;

  /// Прогресс раскрашивания 0.0..1.0.
  final double progress;

  /// PNG-превью для карточки галереи (снапшот холста).
  final Uint8List? thumbnail;

  /// Путь к исходному PDF (для повторной растеризации при необходимости).
  final String? sourcePdfPath;

  /// Индекс выбранной страницы в исходном PDF.
  final int pageIndex;
  final DateTime createdAt;
  final DateTime updatedAt;
  const ArtworkRow({
    required this.id,
    required this.title,
    this.bookId,
    required this.status,
    required this.progress,
    this.thumbnail,
    this.sourcePdfPath,
    required this.pageIndex,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || bookId != null) {
      map['book_id'] = Variable<int>(bookId);
    }
    map['status'] = Variable<int>(status);
    map['progress'] = Variable<double>(progress);
    if (!nullToAbsent || thumbnail != null) {
      map['thumbnail'] = Variable<Uint8List>(thumbnail);
    }
    if (!nullToAbsent || sourcePdfPath != null) {
      map['source_pdf_path'] = Variable<String>(sourcePdfPath);
    }
    map['page_index'] = Variable<int>(pageIndex);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ArtworksCompanion toCompanion(bool nullToAbsent) {
    return ArtworksCompanion(
      id: Value(id),
      title: Value(title),
      bookId: bookId == null && nullToAbsent
          ? const Value.absent()
          : Value(bookId),
      status: Value(status),
      progress: Value(progress),
      thumbnail: thumbnail == null && nullToAbsent
          ? const Value.absent()
          : Value(thumbnail),
      sourcePdfPath: sourcePdfPath == null && nullToAbsent
          ? const Value.absent()
          : Value(sourcePdfPath),
      pageIndex: Value(pageIndex),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ArtworkRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ArtworkRow(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      bookId: serializer.fromJson<int?>(json['bookId']),
      status: serializer.fromJson<int>(json['status']),
      progress: serializer.fromJson<double>(json['progress']),
      thumbnail: serializer.fromJson<Uint8List?>(json['thumbnail']),
      sourcePdfPath: serializer.fromJson<String?>(json['sourcePdfPath']),
      pageIndex: serializer.fromJson<int>(json['pageIndex']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'bookId': serializer.toJson<int?>(bookId),
      'status': serializer.toJson<int>(status),
      'progress': serializer.toJson<double>(progress),
      'thumbnail': serializer.toJson<Uint8List?>(thumbnail),
      'sourcePdfPath': serializer.toJson<String?>(sourcePdfPath),
      'pageIndex': serializer.toJson<int>(pageIndex),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ArtworkRow copyWith({
    int? id,
    String? title,
    Value<int?> bookId = const Value.absent(),
    int? status,
    double? progress,
    Value<Uint8List?> thumbnail = const Value.absent(),
    Value<String?> sourcePdfPath = const Value.absent(),
    int? pageIndex,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ArtworkRow(
    id: id ?? this.id,
    title: title ?? this.title,
    bookId: bookId.present ? bookId.value : this.bookId,
    status: status ?? this.status,
    progress: progress ?? this.progress,
    thumbnail: thumbnail.present ? thumbnail.value : this.thumbnail,
    sourcePdfPath: sourcePdfPath.present
        ? sourcePdfPath.value
        : this.sourcePdfPath,
    pageIndex: pageIndex ?? this.pageIndex,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ArtworkRow copyWithCompanion(ArtworksCompanion data) {
    return ArtworkRow(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      bookId: data.bookId.present ? data.bookId.value : this.bookId,
      status: data.status.present ? data.status.value : this.status,
      progress: data.progress.present ? data.progress.value : this.progress,
      thumbnail: data.thumbnail.present ? data.thumbnail.value : this.thumbnail,
      sourcePdfPath: data.sourcePdfPath.present
          ? data.sourcePdfPath.value
          : this.sourcePdfPath,
      pageIndex: data.pageIndex.present ? data.pageIndex.value : this.pageIndex,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ArtworkRow(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('bookId: $bookId, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('sourcePdfPath: $sourcePdfPath, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    bookId,
    status,
    progress,
    $driftBlobEquality.hash(thumbnail),
    sourcePdfPath,
    pageIndex,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ArtworkRow &&
          other.id == this.id &&
          other.title == this.title &&
          other.bookId == this.bookId &&
          other.status == this.status &&
          other.progress == this.progress &&
          $driftBlobEquality.equals(other.thumbnail, this.thumbnail) &&
          other.sourcePdfPath == this.sourcePdfPath &&
          other.pageIndex == this.pageIndex &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ArtworksCompanion extends UpdateCompanion<ArtworkRow> {
  final Value<int> id;
  final Value<String> title;
  final Value<int?> bookId;
  final Value<int> status;
  final Value<double> progress;
  final Value<Uint8List?> thumbnail;
  final Value<String?> sourcePdfPath;
  final Value<int> pageIndex;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ArtworksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.bookId = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.sourcePdfPath = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ArtworksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.bookId = const Value.absent(),
    this.status = const Value.absent(),
    this.progress = const Value.absent(),
    this.thumbnail = const Value.absent(),
    this.sourcePdfPath = const Value.absent(),
    this.pageIndex = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : title = Value(title);
  static Insertable<ArtworkRow> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<int>? bookId,
    Expression<int>? status,
    Expression<double>? progress,
    Expression<Uint8List>? thumbnail,
    Expression<String>? sourcePdfPath,
    Expression<int>? pageIndex,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (bookId != null) 'book_id': bookId,
      if (status != null) 'status': status,
      if (progress != null) 'progress': progress,
      if (thumbnail != null) 'thumbnail': thumbnail,
      if (sourcePdfPath != null) 'source_pdf_path': sourcePdfPath,
      if (pageIndex != null) 'page_index': pageIndex,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ArtworksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<int?>? bookId,
    Value<int>? status,
    Value<double>? progress,
    Value<Uint8List?>? thumbnail,
    Value<String?>? sourcePdfPath,
    Value<int>? pageIndex,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ArtworksCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      bookId: bookId ?? this.bookId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      thumbnail: thumbnail ?? this.thumbnail,
      sourcePdfPath: sourcePdfPath ?? this.sourcePdfPath,
      pageIndex: pageIndex ?? this.pageIndex,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (bookId.present) {
      map['book_id'] = Variable<int>(bookId.value);
    }
    if (status.present) {
      map['status'] = Variable<int>(status.value);
    }
    if (progress.present) {
      map['progress'] = Variable<double>(progress.value);
    }
    if (thumbnail.present) {
      map['thumbnail'] = Variable<Uint8List>(thumbnail.value);
    }
    if (sourcePdfPath.present) {
      map['source_pdf_path'] = Variable<String>(sourcePdfPath.value);
    }
    if (pageIndex.present) {
      map['page_index'] = Variable<int>(pageIndex.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ArtworksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('bookId: $bookId, ')
          ..write('status: $status, ')
          ..write('progress: $progress, ')
          ..write('thumbnail: $thumbnail, ')
          ..write('sourcePdfPath: $sourcePdfPath, ')
          ..write('pageIndex: $pageIndex, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CvCacheEntriesTable extends CvCacheEntries
    with TableInfo<$CvCacheEntriesTable, CvCacheEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CvCacheEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _artworkIdMeta = const VerificationMeta(
    'artworkId',
  );
  @override
  late final GeneratedColumn<int> artworkId = GeneratedColumn<int>(
    'artwork_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES artworks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _widthMeta = const VerificationMeta('width');
  @override
  late final GeneratedColumn<int> width = GeneratedColumn<int>(
    'width',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _heightMeta = const VerificationMeta('height');
  @override
  late final GeneratedColumn<int> height = GeneratedColumn<int>(
    'height',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMapMeta = const VerificationMeta(
    'labelMap',
  );
  @override
  late final GeneratedColumn<Uint8List> labelMap = GeneratedColumn<Uint8List>(
    'label_map',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enhancedImageMeta = const VerificationMeta(
    'enhancedImage',
  );
  @override
  late final GeneratedColumn<Uint8List> enhancedImage =
      GeneratedColumn<Uint8List>(
        'enhanced_image',
        aliasedName,
        false,
        type: DriftSqlType.blob,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _originalImageMeta = const VerificationMeta(
    'originalImage',
  );
  @override
  late final GeneratedColumn<Uint8List> originalImage =
      GeneratedColumn<Uint8List>(
        'original_image',
        aliasedName,
        true,
        type: DriftSqlType.blob,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _regionsJsonMeta = const VerificationMeta(
    'regionsJson',
  );
  @override
  late final GeneratedColumn<String> regionsJson = GeneratedColumn<String>(
    'regions_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    artworkId,
    width,
    height,
    labelMap,
    enhancedImage,
    originalImage,
    regionsJson,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'cv_cache_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<CvCacheEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('artwork_id')) {
      context.handle(
        _artworkIdMeta,
        artworkId.isAcceptableOrUnknown(data['artwork_id']!, _artworkIdMeta),
      );
    }
    if (data.containsKey('width')) {
      context.handle(
        _widthMeta,
        width.isAcceptableOrUnknown(data['width']!, _widthMeta),
      );
    } else if (isInserting) {
      context.missing(_widthMeta);
    }
    if (data.containsKey('height')) {
      context.handle(
        _heightMeta,
        height.isAcceptableOrUnknown(data['height']!, _heightMeta),
      );
    } else if (isInserting) {
      context.missing(_heightMeta);
    }
    if (data.containsKey('label_map')) {
      context.handle(
        _labelMapMeta,
        labelMap.isAcceptableOrUnknown(data['label_map']!, _labelMapMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMapMeta);
    }
    if (data.containsKey('enhanced_image')) {
      context.handle(
        _enhancedImageMeta,
        enhancedImage.isAcceptableOrUnknown(
          data['enhanced_image']!,
          _enhancedImageMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_enhancedImageMeta);
    }
    if (data.containsKey('original_image')) {
      context.handle(
        _originalImageMeta,
        originalImage.isAcceptableOrUnknown(
          data['original_image']!,
          _originalImageMeta,
        ),
      );
    }
    if (data.containsKey('regions_json')) {
      context.handle(
        _regionsJsonMeta,
        regionsJson.isAcceptableOrUnknown(
          data['regions_json']!,
          _regionsJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_regionsJsonMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {artworkId};
  @override
  CvCacheEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CvCacheEntry(
      artworkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artwork_id'],
      )!,
      width: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}width'],
      )!,
      height: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}height'],
      )!,
      labelMap: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}label_map'],
      )!,
      enhancedImage: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}enhanced_image'],
      )!,
      originalImage: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}original_image'],
      ),
      regionsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}regions_json'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CvCacheEntriesTable createAlias(String alias) {
    return $CvCacheEntriesTable(attachedDatabase, alias);
  }
}

class CvCacheEntry extends DataClass implements Insertable<CvCacheEntry> {
  final int artworkId;
  final int width;
  final int height;

  /// Label-map: сырые байты Int32List длиной width*height.
  final Uint8List labelMap;

  /// Улучшенный line-art (display-версия) в виде PNG.
  final Uint8List enhancedImage;

  /// Оригинал страницы (PNG без обработок, тот же размер, что display) —
  /// для режима «показать оригинал» на экране рисования.
  final Uint8List? originalImage;

  /// JSON-список регионов (id, площадь, bbox, центроид номера).
  final String regionsJson;
  final DateTime createdAt;
  const CvCacheEntry({
    required this.artworkId,
    required this.width,
    required this.height,
    required this.labelMap,
    required this.enhancedImage,
    this.originalImage,
    required this.regionsJson,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['artwork_id'] = Variable<int>(artworkId);
    map['width'] = Variable<int>(width);
    map['height'] = Variable<int>(height);
    map['label_map'] = Variable<Uint8List>(labelMap);
    map['enhanced_image'] = Variable<Uint8List>(enhancedImage);
    if (!nullToAbsent || originalImage != null) {
      map['original_image'] = Variable<Uint8List>(originalImage);
    }
    map['regions_json'] = Variable<String>(regionsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CvCacheEntriesCompanion toCompanion(bool nullToAbsent) {
    return CvCacheEntriesCompanion(
      artworkId: Value(artworkId),
      width: Value(width),
      height: Value(height),
      labelMap: Value(labelMap),
      enhancedImage: Value(enhancedImage),
      originalImage: originalImage == null && nullToAbsent
          ? const Value.absent()
          : Value(originalImage),
      regionsJson: Value(regionsJson),
      createdAt: Value(createdAt),
    );
  }

  factory CvCacheEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CvCacheEntry(
      artworkId: serializer.fromJson<int>(json['artworkId']),
      width: serializer.fromJson<int>(json['width']),
      height: serializer.fromJson<int>(json['height']),
      labelMap: serializer.fromJson<Uint8List>(json['labelMap']),
      enhancedImage: serializer.fromJson<Uint8List>(json['enhancedImage']),
      originalImage: serializer.fromJson<Uint8List?>(json['originalImage']),
      regionsJson: serializer.fromJson<String>(json['regionsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'artworkId': serializer.toJson<int>(artworkId),
      'width': serializer.toJson<int>(width),
      'height': serializer.toJson<int>(height),
      'labelMap': serializer.toJson<Uint8List>(labelMap),
      'enhancedImage': serializer.toJson<Uint8List>(enhancedImage),
      'originalImage': serializer.toJson<Uint8List?>(originalImage),
      'regionsJson': serializer.toJson<String>(regionsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CvCacheEntry copyWith({
    int? artworkId,
    int? width,
    int? height,
    Uint8List? labelMap,
    Uint8List? enhancedImage,
    Value<Uint8List?> originalImage = const Value.absent(),
    String? regionsJson,
    DateTime? createdAt,
  }) => CvCacheEntry(
    artworkId: artworkId ?? this.artworkId,
    width: width ?? this.width,
    height: height ?? this.height,
    labelMap: labelMap ?? this.labelMap,
    enhancedImage: enhancedImage ?? this.enhancedImage,
    originalImage: originalImage.present
        ? originalImage.value
        : this.originalImage,
    regionsJson: regionsJson ?? this.regionsJson,
    createdAt: createdAt ?? this.createdAt,
  );
  CvCacheEntry copyWithCompanion(CvCacheEntriesCompanion data) {
    return CvCacheEntry(
      artworkId: data.artworkId.present ? data.artworkId.value : this.artworkId,
      width: data.width.present ? data.width.value : this.width,
      height: data.height.present ? data.height.value : this.height,
      labelMap: data.labelMap.present ? data.labelMap.value : this.labelMap,
      enhancedImage: data.enhancedImage.present
          ? data.enhancedImage.value
          : this.enhancedImage,
      originalImage: data.originalImage.present
          ? data.originalImage.value
          : this.originalImage,
      regionsJson: data.regionsJson.present
          ? data.regionsJson.value
          : this.regionsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CvCacheEntry(')
          ..write('artworkId: $artworkId, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('labelMap: $labelMap, ')
          ..write('enhancedImage: $enhancedImage, ')
          ..write('originalImage: $originalImage, ')
          ..write('regionsJson: $regionsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    artworkId,
    width,
    height,
    $driftBlobEquality.hash(labelMap),
    $driftBlobEquality.hash(enhancedImage),
    $driftBlobEquality.hash(originalImage),
    regionsJson,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CvCacheEntry &&
          other.artworkId == this.artworkId &&
          other.width == this.width &&
          other.height == this.height &&
          $driftBlobEquality.equals(other.labelMap, this.labelMap) &&
          $driftBlobEquality.equals(other.enhancedImage, this.enhancedImage) &&
          $driftBlobEquality.equals(other.originalImage, this.originalImage) &&
          other.regionsJson == this.regionsJson &&
          other.createdAt == this.createdAt);
}

class CvCacheEntriesCompanion extends UpdateCompanion<CvCacheEntry> {
  final Value<int> artworkId;
  final Value<int> width;
  final Value<int> height;
  final Value<Uint8List> labelMap;
  final Value<Uint8List> enhancedImage;
  final Value<Uint8List?> originalImage;
  final Value<String> regionsJson;
  final Value<DateTime> createdAt;
  const CvCacheEntriesCompanion({
    this.artworkId = const Value.absent(),
    this.width = const Value.absent(),
    this.height = const Value.absent(),
    this.labelMap = const Value.absent(),
    this.enhancedImage = const Value.absent(),
    this.originalImage = const Value.absent(),
    this.regionsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CvCacheEntriesCompanion.insert({
    this.artworkId = const Value.absent(),
    required int width,
    required int height,
    required Uint8List labelMap,
    required Uint8List enhancedImage,
    this.originalImage = const Value.absent(),
    required String regionsJson,
    this.createdAt = const Value.absent(),
  }) : width = Value(width),
       height = Value(height),
       labelMap = Value(labelMap),
       enhancedImage = Value(enhancedImage),
       regionsJson = Value(regionsJson);
  static Insertable<CvCacheEntry> custom({
    Expression<int>? artworkId,
    Expression<int>? width,
    Expression<int>? height,
    Expression<Uint8List>? labelMap,
    Expression<Uint8List>? enhancedImage,
    Expression<Uint8List>? originalImage,
    Expression<String>? regionsJson,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (artworkId != null) 'artwork_id': artworkId,
      if (width != null) 'width': width,
      if (height != null) 'height': height,
      if (labelMap != null) 'label_map': labelMap,
      if (enhancedImage != null) 'enhanced_image': enhancedImage,
      if (originalImage != null) 'original_image': originalImage,
      if (regionsJson != null) 'regions_json': regionsJson,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CvCacheEntriesCompanion copyWith({
    Value<int>? artworkId,
    Value<int>? width,
    Value<int>? height,
    Value<Uint8List>? labelMap,
    Value<Uint8List>? enhancedImage,
    Value<Uint8List?>? originalImage,
    Value<String>? regionsJson,
    Value<DateTime>? createdAt,
  }) {
    return CvCacheEntriesCompanion(
      artworkId: artworkId ?? this.artworkId,
      width: width ?? this.width,
      height: height ?? this.height,
      labelMap: labelMap ?? this.labelMap,
      enhancedImage: enhancedImage ?? this.enhancedImage,
      originalImage: originalImage ?? this.originalImage,
      regionsJson: regionsJson ?? this.regionsJson,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (artworkId.present) {
      map['artwork_id'] = Variable<int>(artworkId.value);
    }
    if (width.present) {
      map['width'] = Variable<int>(width.value);
    }
    if (height.present) {
      map['height'] = Variable<int>(height.value);
    }
    if (labelMap.present) {
      map['label_map'] = Variable<Uint8List>(labelMap.value);
    }
    if (enhancedImage.present) {
      map['enhanced_image'] = Variable<Uint8List>(enhancedImage.value);
    }
    if (originalImage.present) {
      map['original_image'] = Variable<Uint8List>(originalImage.value);
    }
    if (regionsJson.present) {
      map['regions_json'] = Variable<String>(regionsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CvCacheEntriesCompanion(')
          ..write('artworkId: $artworkId, ')
          ..write('width: $width, ')
          ..write('height: $height, ')
          ..write('labelMap: $labelMap, ')
          ..write('enhancedImage: $enhancedImage, ')
          ..write('originalImage: $originalImage, ')
          ..write('regionsJson: $regionsJson, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $StrokesTable extends Strokes with TableInfo<$StrokesTable, Stroke> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StrokesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _artworkIdMeta = const VerificationMeta(
    'artworkId',
  );
  @override
  late final GeneratedColumn<int> artworkId = GeneratedColumn<int>(
    'artwork_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES artworks (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _seqMeta = const VerificationMeta('seq');
  @override
  late final GeneratedColumn<int> seq = GeneratedColumn<int>(
    'seq',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _regionIdMeta = const VerificationMeta(
    'regionId',
  );
  @override
  late final GeneratedColumn<int> regionId = GeneratedColumn<int>(
    'region_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
    'color',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opacityMeta = const VerificationMeta(
    'opacity',
  );
  @override
  late final GeneratedColumn<double> opacity = GeneratedColumn<double>(
    'opacity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _brushSizeMeta = const VerificationMeta(
    'brushSize',
  );
  @override
  late final GeneratedColumn<double> brushSize = GeneratedColumn<double>(
    'brush_size',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(24),
  );
  static const VerificationMeta _pointsMeta = const VerificationMeta('points');
  @override
  late final GeneratedColumn<Uint8List> points = GeneratedColumn<Uint8List>(
    'points',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    artworkId,
    seq,
    regionId,
    color,
    opacity,
    brushSize,
    points,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'strokes';
  @override
  VerificationContext validateIntegrity(
    Insertable<Stroke> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('artwork_id')) {
      context.handle(
        _artworkIdMeta,
        artworkId.isAcceptableOrUnknown(data['artwork_id']!, _artworkIdMeta),
      );
    } else if (isInserting) {
      context.missing(_artworkIdMeta);
    }
    if (data.containsKey('seq')) {
      context.handle(
        _seqMeta,
        seq.isAcceptableOrUnknown(data['seq']!, _seqMeta),
      );
    } else if (isInserting) {
      context.missing(_seqMeta);
    }
    if (data.containsKey('region_id')) {
      context.handle(
        _regionIdMeta,
        regionId.isAcceptableOrUnknown(data['region_id']!, _regionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_regionIdMeta);
    }
    if (data.containsKey('color')) {
      context.handle(
        _colorMeta,
        color.isAcceptableOrUnknown(data['color']!, _colorMeta),
      );
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('opacity')) {
      context.handle(
        _opacityMeta,
        opacity.isAcceptableOrUnknown(data['opacity']!, _opacityMeta),
      );
    }
    if (data.containsKey('brush_size')) {
      context.handle(
        _brushSizeMeta,
        brushSize.isAcceptableOrUnknown(data['brush_size']!, _brushSizeMeta),
      );
    }
    if (data.containsKey('points')) {
      context.handle(
        _pointsMeta,
        points.isAcceptableOrUnknown(data['points']!, _pointsMeta),
      );
    } else if (isInserting) {
      context.missing(_pointsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Stroke map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Stroke(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      artworkId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}artwork_id'],
      )!,
      seq: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}seq'],
      )!,
      regionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}region_id'],
      )!,
      color: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}color'],
      )!,
      opacity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}opacity'],
      )!,
      brushSize: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}brush_size'],
      )!,
      points: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}points'],
      )!,
    );
  }

  @override
  $StrokesTable createAlias(String alias) {
    return $StrokesTable(attachedDatabase, alias);
  }
}

class Stroke extends DataClass implements Insertable<Stroke> {
  final int id;
  final int artworkId;

  /// Порядковый номер мазка (для реплея и undo/redo).
  final int seq;

  /// Регион, по маске которого клиппился мазок.
  final int regionId;

  /// Цвет мазка (ARGB int).
  final int color;
  final double opacity;
  final double brushSize;

  /// Упакованные координаты точек мазка (Float32List: x0,y0,x1,y1,…).
  final Uint8List points;
  const Stroke({
    required this.id,
    required this.artworkId,
    required this.seq,
    required this.regionId,
    required this.color,
    required this.opacity,
    required this.brushSize,
    required this.points,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['artwork_id'] = Variable<int>(artworkId);
    map['seq'] = Variable<int>(seq);
    map['region_id'] = Variable<int>(regionId);
    map['color'] = Variable<int>(color);
    map['opacity'] = Variable<double>(opacity);
    map['brush_size'] = Variable<double>(brushSize);
    map['points'] = Variable<Uint8List>(points);
    return map;
  }

  StrokesCompanion toCompanion(bool nullToAbsent) {
    return StrokesCompanion(
      id: Value(id),
      artworkId: Value(artworkId),
      seq: Value(seq),
      regionId: Value(regionId),
      color: Value(color),
      opacity: Value(opacity),
      brushSize: Value(brushSize),
      points: Value(points),
    );
  }

  factory Stroke.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Stroke(
      id: serializer.fromJson<int>(json['id']),
      artworkId: serializer.fromJson<int>(json['artworkId']),
      seq: serializer.fromJson<int>(json['seq']),
      regionId: serializer.fromJson<int>(json['regionId']),
      color: serializer.fromJson<int>(json['color']),
      opacity: serializer.fromJson<double>(json['opacity']),
      brushSize: serializer.fromJson<double>(json['brushSize']),
      points: serializer.fromJson<Uint8List>(json['points']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'artworkId': serializer.toJson<int>(artworkId),
      'seq': serializer.toJson<int>(seq),
      'regionId': serializer.toJson<int>(regionId),
      'color': serializer.toJson<int>(color),
      'opacity': serializer.toJson<double>(opacity),
      'brushSize': serializer.toJson<double>(brushSize),
      'points': serializer.toJson<Uint8List>(points),
    };
  }

  Stroke copyWith({
    int? id,
    int? artworkId,
    int? seq,
    int? regionId,
    int? color,
    double? opacity,
    double? brushSize,
    Uint8List? points,
  }) => Stroke(
    id: id ?? this.id,
    artworkId: artworkId ?? this.artworkId,
    seq: seq ?? this.seq,
    regionId: regionId ?? this.regionId,
    color: color ?? this.color,
    opacity: opacity ?? this.opacity,
    brushSize: brushSize ?? this.brushSize,
    points: points ?? this.points,
  );
  Stroke copyWithCompanion(StrokesCompanion data) {
    return Stroke(
      id: data.id.present ? data.id.value : this.id,
      artworkId: data.artworkId.present ? data.artworkId.value : this.artworkId,
      seq: data.seq.present ? data.seq.value : this.seq,
      regionId: data.regionId.present ? data.regionId.value : this.regionId,
      color: data.color.present ? data.color.value : this.color,
      opacity: data.opacity.present ? data.opacity.value : this.opacity,
      brushSize: data.brushSize.present ? data.brushSize.value : this.brushSize,
      points: data.points.present ? data.points.value : this.points,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Stroke(')
          ..write('id: $id, ')
          ..write('artworkId: $artworkId, ')
          ..write('seq: $seq, ')
          ..write('regionId: $regionId, ')
          ..write('color: $color, ')
          ..write('opacity: $opacity, ')
          ..write('brushSize: $brushSize, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    artworkId,
    seq,
    regionId,
    color,
    opacity,
    brushSize,
    $driftBlobEquality.hash(points),
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Stroke &&
          other.id == this.id &&
          other.artworkId == this.artworkId &&
          other.seq == this.seq &&
          other.regionId == this.regionId &&
          other.color == this.color &&
          other.opacity == this.opacity &&
          other.brushSize == this.brushSize &&
          $driftBlobEquality.equals(other.points, this.points));
}

class StrokesCompanion extends UpdateCompanion<Stroke> {
  final Value<int> id;
  final Value<int> artworkId;
  final Value<int> seq;
  final Value<int> regionId;
  final Value<int> color;
  final Value<double> opacity;
  final Value<double> brushSize;
  final Value<Uint8List> points;
  const StrokesCompanion({
    this.id = const Value.absent(),
    this.artworkId = const Value.absent(),
    this.seq = const Value.absent(),
    this.regionId = const Value.absent(),
    this.color = const Value.absent(),
    this.opacity = const Value.absent(),
    this.brushSize = const Value.absent(),
    this.points = const Value.absent(),
  });
  StrokesCompanion.insert({
    this.id = const Value.absent(),
    required int artworkId,
    required int seq,
    required int regionId,
    required int color,
    this.opacity = const Value.absent(),
    this.brushSize = const Value.absent(),
    required Uint8List points,
  }) : artworkId = Value(artworkId),
       seq = Value(seq),
       regionId = Value(regionId),
       color = Value(color),
       points = Value(points);
  static Insertable<Stroke> custom({
    Expression<int>? id,
    Expression<int>? artworkId,
    Expression<int>? seq,
    Expression<int>? regionId,
    Expression<int>? color,
    Expression<double>? opacity,
    Expression<double>? brushSize,
    Expression<Uint8List>? points,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (artworkId != null) 'artwork_id': artworkId,
      if (seq != null) 'seq': seq,
      if (regionId != null) 'region_id': regionId,
      if (color != null) 'color': color,
      if (opacity != null) 'opacity': opacity,
      if (brushSize != null) 'brush_size': brushSize,
      if (points != null) 'points': points,
    });
  }

  StrokesCompanion copyWith({
    Value<int>? id,
    Value<int>? artworkId,
    Value<int>? seq,
    Value<int>? regionId,
    Value<int>? color,
    Value<double>? opacity,
    Value<double>? brushSize,
    Value<Uint8List>? points,
  }) {
    return StrokesCompanion(
      id: id ?? this.id,
      artworkId: artworkId ?? this.artworkId,
      seq: seq ?? this.seq,
      regionId: regionId ?? this.regionId,
      color: color ?? this.color,
      opacity: opacity ?? this.opacity,
      brushSize: brushSize ?? this.brushSize,
      points: points ?? this.points,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (artworkId.present) {
      map['artwork_id'] = Variable<int>(artworkId.value);
    }
    if (seq.present) {
      map['seq'] = Variable<int>(seq.value);
    }
    if (regionId.present) {
      map['region_id'] = Variable<int>(regionId.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (opacity.present) {
      map['opacity'] = Variable<double>(opacity.value);
    }
    if (brushSize.present) {
      map['brush_size'] = Variable<double>(brushSize.value);
    }
    if (points.present) {
      map['points'] = Variable<Uint8List>(points.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StrokesCompanion(')
          ..write('id: $id, ')
          ..write('artworkId: $artworkId, ')
          ..write('seq: $seq, ')
          ..write('regionId: $regionId, ')
          ..write('color: $color, ')
          ..write('opacity: $opacity, ')
          ..write('brushSize: $brushSize, ')
          ..write('points: $points')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BooksTable books = $BooksTable(this);
  late final $ArtworksTable artworks = $ArtworksTable(this);
  late final $CvCacheEntriesTable cvCacheEntries = $CvCacheEntriesTable(this);
  late final $StrokesTable strokes = $StrokesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    books,
    artworks,
    cvCacheEntries,
    strokes,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'books',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('artworks', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'artworks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('cv_cache_entries', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'artworks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('strokes', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$BooksTableCreateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      required String title,
      Value<String?> sourcePdfPath,
      Value<Uint8List?> cover,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$BooksTableUpdateCompanionBuilder =
    BooksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String?> sourcePdfPath,
      Value<Uint8List?> cover,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$BooksTableReferences
    extends BaseReferences<_$AppDatabase, $BooksTable, BookRow> {
  $$BooksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ArtworksTable, List<ArtworkRow>>
  _artworksRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.artworks,
    aliasName: 'books__id__artworks__book_id',
  );

  $$ArtworksTableProcessedTableManager get artworksRefs {
    final manager = $$ArtworksTableTableManager(
      $_db,
      $_db.artworks,
    ).filter((f) => f.bookId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_artworksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$BooksTableFilterComposer extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourcePdfPath => $composableBuilder(
    column: $table.sourcePdfPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> artworksRefs(
    Expression<bool> Function($$ArtworksTableFilterComposer f) f,
  ) {
    final $$ArtworksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.artworks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtworksTableFilterComposer(
            $db: $db,
            $table: $db.artworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableOrderingComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourcePdfPath => $composableBuilder(
    column: $table.sourcePdfPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get cover => $composableBuilder(
    column: $table.cover,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BooksTableAnnotationComposer
    extends Composer<_$AppDatabase, $BooksTable> {
  $$BooksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get sourcePdfPath => $composableBuilder(
    column: $table.sourcePdfPath,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get cover =>
      $composableBuilder(column: $table.cover, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> artworksRefs<T extends Object>(
    Expression<T> Function($$ArtworksTableAnnotationComposer a) f,
  ) {
    final $$ArtworksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.artworks,
      getReferencedColumn: (t) => t.bookId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtworksTableAnnotationComposer(
            $db: $db,
            $table: $db.artworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$BooksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BooksTable,
          BookRow,
          $$BooksTableFilterComposer,
          $$BooksTableOrderingComposer,
          $$BooksTableAnnotationComposer,
          $$BooksTableCreateCompanionBuilder,
          $$BooksTableUpdateCompanionBuilder,
          (BookRow, $$BooksTableReferences),
          BookRow,
          PrefetchHooks Function({bool artworksRefs})
        > {
  $$BooksTableTableManager(_$AppDatabase db, $BooksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BooksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BooksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BooksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> sourcePdfPath = const Value.absent(),
                Value<Uint8List?> cover = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BooksCompanion(
                id: id,
                title: title,
                sourcePdfPath: sourcePdfPath,
                cover: cover,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String?> sourcePdfPath = const Value.absent(),
                Value<Uint8List?> cover = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => BooksCompanion.insert(
                id: id,
                title: title,
                sourcePdfPath: sourcePdfPath,
                cover: cover,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$BooksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({artworksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (artworksRefs) db.artworks],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (artworksRefs)
                    await $_getPrefetchedData<BookRow, $BooksTable, ArtworkRow>(
                      currentTable: table,
                      referencedTable: $$BooksTableReferences
                          ._artworksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$BooksTableReferences(db, table, p0).artworksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.bookId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$BooksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BooksTable,
      BookRow,
      $$BooksTableFilterComposer,
      $$BooksTableOrderingComposer,
      $$BooksTableAnnotationComposer,
      $$BooksTableCreateCompanionBuilder,
      $$BooksTableUpdateCompanionBuilder,
      (BookRow, $$BooksTableReferences),
      BookRow,
      PrefetchHooks Function({bool artworksRefs})
    >;
typedef $$ArtworksTableCreateCompanionBuilder =
    ArtworksCompanion Function({
      Value<int> id,
      required String title,
      Value<int?> bookId,
      Value<int> status,
      Value<double> progress,
      Value<Uint8List?> thumbnail,
      Value<String?> sourcePdfPath,
      Value<int> pageIndex,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });
typedef $$ArtworksTableUpdateCompanionBuilder =
    ArtworksCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<int?> bookId,
      Value<int> status,
      Value<double> progress,
      Value<Uint8List?> thumbnail,
      Value<String?> sourcePdfPath,
      Value<int> pageIndex,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$ArtworksTableReferences
    extends BaseReferences<_$AppDatabase, $ArtworksTable, ArtworkRow> {
  $$ArtworksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $BooksTable _bookIdTable(_$AppDatabase db) =>
      db.books.createAlias('artworks__book_id__books__id');

  $$BooksTableProcessedTableManager? get bookId {
    final $_column = $_itemColumn<int>('book_id');
    if ($_column == null) return null;
    final manager = $$BooksTableTableManager(
      $_db,
      $_db.books,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_bookIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$CvCacheEntriesTable, List<CvCacheEntry>>
  _cvCacheEntriesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.cvCacheEntries,
    aliasName: 'artworks__id__cv_cache_entries__artwork_id',
  );

  $$CvCacheEntriesTableProcessedTableManager get cvCacheEntriesRefs {
    final manager = $$CvCacheEntriesTableTableManager(
      $_db,
      $_db.cvCacheEntries,
    ).filter((f) => f.artworkId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_cvCacheEntriesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$StrokesTable, List<Stroke>> _strokesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.strokes,
    aliasName: 'artworks__id__strokes__artwork_id',
  );

  $$StrokesTableProcessedTableManager get strokesRefs {
    final manager = $$StrokesTableTableManager(
      $_db,
      $_db.strokes,
    ).filter((f) => f.artworkId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_strokesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ArtworksTableFilterComposer
    extends Composer<_$AppDatabase, $ArtworksTable> {
  $$ArtworksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourcePdfPath => $composableBuilder(
    column: $table.sourcePdfPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$BooksTableFilterComposer get bookId {
    final $$BooksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableFilterComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> cvCacheEntriesRefs(
    Expression<bool> Function($$CvCacheEntriesTableFilterComposer f) f,
  ) {
    final $$CvCacheEntriesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cvCacheEntries,
      getReferencedColumn: (t) => t.artworkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CvCacheEntriesTableFilterComposer(
            $db: $db,
            $table: $db.cvCacheEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> strokesRefs(
    Expression<bool> Function($$StrokesTableFilterComposer f) f,
  ) {
    final $$StrokesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strokes,
      getReferencedColumn: (t) => t.artworkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrokesTableFilterComposer(
            $db: $db,
            $table: $db.strokes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtworksTableOrderingComposer
    extends Composer<_$AppDatabase, $ArtworksTable> {
  $$ArtworksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get progress => $composableBuilder(
    column: $table.progress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get thumbnail => $composableBuilder(
    column: $table.thumbnail,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourcePdfPath => $composableBuilder(
    column: $table.sourcePdfPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pageIndex => $composableBuilder(
    column: $table.pageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$BooksTableOrderingComposer get bookId {
    final $$BooksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableOrderingComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ArtworksTableAnnotationComposer
    extends Composer<_$AppDatabase, $ArtworksTable> {
  $$ArtworksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<int> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get progress =>
      $composableBuilder(column: $table.progress, builder: (column) => column);

  GeneratedColumn<Uint8List> get thumbnail =>
      $composableBuilder(column: $table.thumbnail, builder: (column) => column);

  GeneratedColumn<String> get sourcePdfPath => $composableBuilder(
    column: $table.sourcePdfPath,
    builder: (column) => column,
  );

  GeneratedColumn<int> get pageIndex =>
      $composableBuilder(column: $table.pageIndex, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$BooksTableAnnotationComposer get bookId {
    final $$BooksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.bookId,
      referencedTable: $db.books,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$BooksTableAnnotationComposer(
            $db: $db,
            $table: $db.books,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> cvCacheEntriesRefs<T extends Object>(
    Expression<T> Function($$CvCacheEntriesTableAnnotationComposer a) f,
  ) {
    final $$CvCacheEntriesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.cvCacheEntries,
      getReferencedColumn: (t) => t.artworkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CvCacheEntriesTableAnnotationComposer(
            $db: $db,
            $table: $db.cvCacheEntries,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> strokesRefs<T extends Object>(
    Expression<T> Function($$StrokesTableAnnotationComposer a) f,
  ) {
    final $$StrokesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.strokes,
      getReferencedColumn: (t) => t.artworkId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$StrokesTableAnnotationComposer(
            $db: $db,
            $table: $db.strokes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ArtworksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ArtworksTable,
          ArtworkRow,
          $$ArtworksTableFilterComposer,
          $$ArtworksTableOrderingComposer,
          $$ArtworksTableAnnotationComposer,
          $$ArtworksTableCreateCompanionBuilder,
          $$ArtworksTableUpdateCompanionBuilder,
          (ArtworkRow, $$ArtworksTableReferences),
          ArtworkRow,
          PrefetchHooks Function({
            bool bookId,
            bool cvCacheEntriesRefs,
            bool strokesRefs,
          })
        > {
  $$ArtworksTableTableManager(_$AppDatabase db, $ArtworksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ArtworksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ArtworksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ArtworksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<int?> bookId = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<Uint8List?> thumbnail = const Value.absent(),
                Value<String?> sourcePdfPath = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ArtworksCompanion(
                id: id,
                title: title,
                bookId: bookId,
                status: status,
                progress: progress,
                thumbnail: thumbnail,
                sourcePdfPath: sourcePdfPath,
                pageIndex: pageIndex,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<int?> bookId = const Value.absent(),
                Value<int> status = const Value.absent(),
                Value<double> progress = const Value.absent(),
                Value<Uint8List?> thumbnail = const Value.absent(),
                Value<String?> sourcePdfPath = const Value.absent(),
                Value<int> pageIndex = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ArtworksCompanion.insert(
                id: id,
                title: title,
                bookId: bookId,
                status: status,
                progress: progress,
                thumbnail: thumbnail,
                sourcePdfPath: sourcePdfPath,
                pageIndex: pageIndex,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ArtworksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                bookId = false,
                cvCacheEntriesRefs = false,
                strokesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (cvCacheEntriesRefs) db.cvCacheEntries,
                    if (strokesRefs) db.strokes,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (bookId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.bookId,
                                    referencedTable: $$ArtworksTableReferences
                                        ._bookIdTable(db),
                                    referencedColumn: $$ArtworksTableReferences
                                        ._bookIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (cvCacheEntriesRefs)
                        await $_getPrefetchedData<
                          ArtworkRow,
                          $ArtworksTable,
                          CvCacheEntry
                        >(
                          currentTable: table,
                          referencedTable: $$ArtworksTableReferences
                              ._cvCacheEntriesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArtworksTableReferences(
                                db,
                                table,
                                p0,
                              ).cvCacheEntriesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.artworkId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (strokesRefs)
                        await $_getPrefetchedData<
                          ArtworkRow,
                          $ArtworksTable,
                          Stroke
                        >(
                          currentTable: table,
                          referencedTable: $$ArtworksTableReferences
                              ._strokesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$ArtworksTableReferences(
                                db,
                                table,
                                p0,
                              ).strokesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.artworkId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$ArtworksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ArtworksTable,
      ArtworkRow,
      $$ArtworksTableFilterComposer,
      $$ArtworksTableOrderingComposer,
      $$ArtworksTableAnnotationComposer,
      $$ArtworksTableCreateCompanionBuilder,
      $$ArtworksTableUpdateCompanionBuilder,
      (ArtworkRow, $$ArtworksTableReferences),
      ArtworkRow,
      PrefetchHooks Function({
        bool bookId,
        bool cvCacheEntriesRefs,
        bool strokesRefs,
      })
    >;
typedef $$CvCacheEntriesTableCreateCompanionBuilder =
    CvCacheEntriesCompanion Function({
      Value<int> artworkId,
      required int width,
      required int height,
      required Uint8List labelMap,
      required Uint8List enhancedImage,
      Value<Uint8List?> originalImage,
      required String regionsJson,
      Value<DateTime> createdAt,
    });
typedef $$CvCacheEntriesTableUpdateCompanionBuilder =
    CvCacheEntriesCompanion Function({
      Value<int> artworkId,
      Value<int> width,
      Value<int> height,
      Value<Uint8List> labelMap,
      Value<Uint8List> enhancedImage,
      Value<Uint8List?> originalImage,
      Value<String> regionsJson,
      Value<DateTime> createdAt,
    });

final class $$CvCacheEntriesTableReferences
    extends BaseReferences<_$AppDatabase, $CvCacheEntriesTable, CvCacheEntry> {
  $$CvCacheEntriesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ArtworksTable _artworkIdTable(_$AppDatabase db) =>
      db.artworks.createAlias('cv_cache_entries__artwork_id__artworks__id');

  $$ArtworksTableProcessedTableManager get artworkId {
    final $_column = $_itemColumn<int>('artwork_id')!;

    final manager = $$ArtworksTableTableManager(
      $_db,
      $_db.artworks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_artworkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$CvCacheEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $CvCacheEntriesTable> {
  $$CvCacheEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get labelMap => $composableBuilder(
    column: $table.labelMap,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get enhancedImage => $composableBuilder(
    column: $table.enhancedImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get originalImage => $composableBuilder(
    column: $table.originalImage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get regionsJson => $composableBuilder(
    column: $table.regionsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$ArtworksTableFilterComposer get artworkId {
    final $$ArtworksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artworkId,
      referencedTable: $db.artworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtworksTableFilterComposer(
            $db: $db,
            $table: $db.artworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CvCacheEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CvCacheEntriesTable> {
  $$CvCacheEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get width => $composableBuilder(
    column: $table.width,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get height => $composableBuilder(
    column: $table.height,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get labelMap => $composableBuilder(
    column: $table.labelMap,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get enhancedImage => $composableBuilder(
    column: $table.enhancedImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get originalImage => $composableBuilder(
    column: $table.originalImage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get regionsJson => $composableBuilder(
    column: $table.regionsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArtworksTableOrderingComposer get artworkId {
    final $$ArtworksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artworkId,
      referencedTable: $db.artworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtworksTableOrderingComposer(
            $db: $db,
            $table: $db.artworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CvCacheEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CvCacheEntriesTable> {
  $$CvCacheEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get width =>
      $composableBuilder(column: $table.width, builder: (column) => column);

  GeneratedColumn<int> get height =>
      $composableBuilder(column: $table.height, builder: (column) => column);

  GeneratedColumn<Uint8List> get labelMap =>
      $composableBuilder(column: $table.labelMap, builder: (column) => column);

  GeneratedColumn<Uint8List> get enhancedImage => $composableBuilder(
    column: $table.enhancedImage,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get originalImage => $composableBuilder(
    column: $table.originalImage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get regionsJson => $composableBuilder(
    column: $table.regionsJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$ArtworksTableAnnotationComposer get artworkId {
    final $$ArtworksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artworkId,
      referencedTable: $db.artworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtworksTableAnnotationComposer(
            $db: $db,
            $table: $db.artworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$CvCacheEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CvCacheEntriesTable,
          CvCacheEntry,
          $$CvCacheEntriesTableFilterComposer,
          $$CvCacheEntriesTableOrderingComposer,
          $$CvCacheEntriesTableAnnotationComposer,
          $$CvCacheEntriesTableCreateCompanionBuilder,
          $$CvCacheEntriesTableUpdateCompanionBuilder,
          (CvCacheEntry, $$CvCacheEntriesTableReferences),
          CvCacheEntry,
          PrefetchHooks Function({bool artworkId})
        > {
  $$CvCacheEntriesTableTableManager(
    _$AppDatabase db,
    $CvCacheEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CvCacheEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CvCacheEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CvCacheEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> artworkId = const Value.absent(),
                Value<int> width = const Value.absent(),
                Value<int> height = const Value.absent(),
                Value<Uint8List> labelMap = const Value.absent(),
                Value<Uint8List> enhancedImage = const Value.absent(),
                Value<Uint8List?> originalImage = const Value.absent(),
                Value<String> regionsJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CvCacheEntriesCompanion(
                artworkId: artworkId,
                width: width,
                height: height,
                labelMap: labelMap,
                enhancedImage: enhancedImage,
                originalImage: originalImage,
                regionsJson: regionsJson,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> artworkId = const Value.absent(),
                required int width,
                required int height,
                required Uint8List labelMap,
                required Uint8List enhancedImage,
                Value<Uint8List?> originalImage = const Value.absent(),
                required String regionsJson,
                Value<DateTime> createdAt = const Value.absent(),
              }) => CvCacheEntriesCompanion.insert(
                artworkId: artworkId,
                width: width,
                height: height,
                labelMap: labelMap,
                enhancedImage: enhancedImage,
                originalImage: originalImage,
                regionsJson: regionsJson,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CvCacheEntriesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({artworkId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (artworkId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.artworkId,
                                referencedTable: $$CvCacheEntriesTableReferences
                                    ._artworkIdTable(db),
                                referencedColumn:
                                    $$CvCacheEntriesTableReferences
                                        ._artworkIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$CvCacheEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CvCacheEntriesTable,
      CvCacheEntry,
      $$CvCacheEntriesTableFilterComposer,
      $$CvCacheEntriesTableOrderingComposer,
      $$CvCacheEntriesTableAnnotationComposer,
      $$CvCacheEntriesTableCreateCompanionBuilder,
      $$CvCacheEntriesTableUpdateCompanionBuilder,
      (CvCacheEntry, $$CvCacheEntriesTableReferences),
      CvCacheEntry,
      PrefetchHooks Function({bool artworkId})
    >;
typedef $$StrokesTableCreateCompanionBuilder =
    StrokesCompanion Function({
      Value<int> id,
      required int artworkId,
      required int seq,
      required int regionId,
      required int color,
      Value<double> opacity,
      Value<double> brushSize,
      required Uint8List points,
    });
typedef $$StrokesTableUpdateCompanionBuilder =
    StrokesCompanion Function({
      Value<int> id,
      Value<int> artworkId,
      Value<int> seq,
      Value<int> regionId,
      Value<int> color,
      Value<double> opacity,
      Value<double> brushSize,
      Value<Uint8List> points,
    });

final class $$StrokesTableReferences
    extends BaseReferences<_$AppDatabase, $StrokesTable, Stroke> {
  $$StrokesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $ArtworksTable _artworkIdTable(_$AppDatabase db) =>
      db.artworks.createAlias('strokes__artwork_id__artworks__id');

  $$ArtworksTableProcessedTableManager get artworkId {
    final $_column = $_itemColumn<int>('artwork_id')!;

    final manager = $$ArtworksTableTableManager(
      $_db,
      $_db.artworks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_artworkIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$StrokesTableFilterComposer
    extends Composer<_$AppDatabase, $StrokesTable> {
  $$StrokesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get opacity => $composableBuilder(
    column: $table.opacity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get brushSize => $composableBuilder(
    column: $table.brushSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnFilters(column),
  );

  $$ArtworksTableFilterComposer get artworkId {
    final $$ArtworksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artworkId,
      referencedTable: $db.artworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtworksTableFilterComposer(
            $db: $db,
            $table: $db.artworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrokesTableOrderingComposer
    extends Composer<_$AppDatabase, $StrokesTable> {
  $$StrokesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get seq => $composableBuilder(
    column: $table.seq,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get regionId => $composableBuilder(
    column: $table.regionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get color => $composableBuilder(
    column: $table.color,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get opacity => $composableBuilder(
    column: $table.opacity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get brushSize => $composableBuilder(
    column: $table.brushSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get points => $composableBuilder(
    column: $table.points,
    builder: (column) => ColumnOrderings(column),
  );

  $$ArtworksTableOrderingComposer get artworkId {
    final $$ArtworksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artworkId,
      referencedTable: $db.artworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtworksTableOrderingComposer(
            $db: $db,
            $table: $db.artworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrokesTableAnnotationComposer
    extends Composer<_$AppDatabase, $StrokesTable> {
  $$StrokesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get seq =>
      $composableBuilder(column: $table.seq, builder: (column) => column);

  GeneratedColumn<int> get regionId =>
      $composableBuilder(column: $table.regionId, builder: (column) => column);

  GeneratedColumn<int> get color =>
      $composableBuilder(column: $table.color, builder: (column) => column);

  GeneratedColumn<double> get opacity =>
      $composableBuilder(column: $table.opacity, builder: (column) => column);

  GeneratedColumn<double> get brushSize =>
      $composableBuilder(column: $table.brushSize, builder: (column) => column);

  GeneratedColumn<Uint8List> get points =>
      $composableBuilder(column: $table.points, builder: (column) => column);

  $$ArtworksTableAnnotationComposer get artworkId {
    final $$ArtworksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.artworkId,
      referencedTable: $db.artworks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ArtworksTableAnnotationComposer(
            $db: $db,
            $table: $db.artworks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$StrokesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $StrokesTable,
          Stroke,
          $$StrokesTableFilterComposer,
          $$StrokesTableOrderingComposer,
          $$StrokesTableAnnotationComposer,
          $$StrokesTableCreateCompanionBuilder,
          $$StrokesTableUpdateCompanionBuilder,
          (Stroke, $$StrokesTableReferences),
          Stroke,
          PrefetchHooks Function({bool artworkId})
        > {
  $$StrokesTableTableManager(_$AppDatabase db, $StrokesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StrokesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StrokesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StrokesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> artworkId = const Value.absent(),
                Value<int> seq = const Value.absent(),
                Value<int> regionId = const Value.absent(),
                Value<int> color = const Value.absent(),
                Value<double> opacity = const Value.absent(),
                Value<double> brushSize = const Value.absent(),
                Value<Uint8List> points = const Value.absent(),
              }) => StrokesCompanion(
                id: id,
                artworkId: artworkId,
                seq: seq,
                regionId: regionId,
                color: color,
                opacity: opacity,
                brushSize: brushSize,
                points: points,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int artworkId,
                required int seq,
                required int regionId,
                required int color,
                Value<double> opacity = const Value.absent(),
                Value<double> brushSize = const Value.absent(),
                required Uint8List points,
              }) => StrokesCompanion.insert(
                id: id,
                artworkId: artworkId,
                seq: seq,
                regionId: regionId,
                color: color,
                opacity: opacity,
                brushSize: brushSize,
                points: points,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$StrokesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({artworkId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (artworkId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.artworkId,
                                referencedTable: $$StrokesTableReferences
                                    ._artworkIdTable(db),
                                referencedColumn: $$StrokesTableReferences
                                    ._artworkIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$StrokesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $StrokesTable,
      Stroke,
      $$StrokesTableFilterComposer,
      $$StrokesTableOrderingComposer,
      $$StrokesTableAnnotationComposer,
      $$StrokesTableCreateCompanionBuilder,
      $$StrokesTableUpdateCompanionBuilder,
      (Stroke, $$StrokesTableReferences),
      Stroke,
      PrefetchHooks Function({bool artworkId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BooksTableTableManager get books =>
      $$BooksTableTableManager(_db, _db.books);
  $$ArtworksTableTableManager get artworks =>
      $$ArtworksTableTableManager(_db, _db.artworks);
  $$CvCacheEntriesTableTableManager get cvCacheEntries =>
      $$CvCacheEntriesTableTableManager(_db, _db.cvCacheEntries);
  $$StrokesTableTableManager get strokes =>
      $$StrokesTableTableManager(_db, _db.strokes);
}
