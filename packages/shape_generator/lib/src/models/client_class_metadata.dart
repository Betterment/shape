import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/nullability_suffix.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/dart/element/type_visitor.dart';
import 'package:meta/meta.dart';

/// {@template client_class_metadata}
/// Metadata about a constructor or factory method in the client codebase.
/// {@endtemplate}
class ClientClassMetadata {
  /// {@macro client_class_metadata}
  ///
  /// This constructor is only visible for testing purposes. Use
  /// [ClientClassMetadata.fromElement] instead.
  @visibleForTesting
  const ClientClassMetadata({
    required this.baseType,
    this.supertype,
    this.instanceType,
    required this.isAbstract,
    required this.isEnum,
    required this.isMixin,
    required this.constructors,
    required this.fields,
    required this.methods,
    required this.typeParameters,
  });

  /// Constructs a [ClientClassMetadata] from an [Element].
  factory ClientClassMetadata.fromElement(
    Element element, {
    DartType? withInstanceType,
  }) {
    if (element is! ClassElement) {
      throw Exception('Expected a ClassElement.');
    }

    final typeVisitor = _DefaultTypeVisitor();
    element.thisType.accept(typeVisitor);

    return ClientClassMetadata(
      baseType: element.thisType,
      supertype: element.supertype,
      instanceType: withInstanceType ?? typeVisitor.type,
      isAbstract: element.isAbstract,
      isEnum: element is EnumElement,
      isMixin: element is MixinElement,
      constructors: element.constructors
          .where((constructor) => !constructor.isOriginImplicitDefault)
          .toList(),
      fields: {
        for (final field in element.fields)
          if (field.name != null) field.name!: field.type,
      },
      methods: [
        for (final method in element.methods)
          if (method.name != null)
            ClientClassMethodMetadata._(
              name: method.name!,
              returnType: method.returnType,
              parameters: method.formalParameters,
              isAbstract: method.isAbstract,
              isStatic: method.isStatic,
              hasOverride: method.metadata.hasOverride,
            ),
      ],
      typeParameters: element.typeParameters,
    );
  }

  /// The base type of the class.
  ///
  /// For example: `GenericFormField<T>`
  final InterfaceType baseType; // GenericFormField<T>

  /// The supertype of the class.
  ///
  /// For example: `FormField<T?, T?, GenericFormFieldValidationError>`
  final InterfaceType?
  supertype; // FormField<T?, T?, GenericFormFieldValidationError>

  /// The instance type of the class. This is the specific type of the class
  /// with all type parameters resolved.
  ///
  /// For example: `GenericFormField<int>`
  final DartType? instanceType; // GenericFormField<int>

  /// Indicates whether the class is abstract.
  final bool isAbstract;

  /// Indicates whether the class is an enum.
  final bool isEnum;

  /// Indicates whether the class is a mixin.
  final bool isMixin;

  /// The constructors of the class.
  final List<ConstructorElement> constructors;

  /// The fields of the class.
  final Map<String, DartType> fields;

  /// The methods of the class.
  final List<ClientClassMethodMetadata> methods;

  /// The type parameters of the class.
  final List<TypeParameterElement> typeParameters;

  /// The base name of the class (based on the [baseType]).
  String get name {
    final display = baseType.getDisplayString();
    if (baseType.nullabilitySuffix == NullabilitySuffix.question &&
        display.endsWith('?')) {
      return display.substring(0, display.length - 1);
    }
    return display;
  }

  /// Whether this is a valid class or subclass that can be used to generate
  /// form body code.
  bool get isValid => isAbstract && !isEnum && !isMixin;

  @override
  String toString() {
    return 'ClientClassMetadata('
        'baseType: $baseType, '
        'supertype: $supertype, '
        'instanceType: $instanceType, '
        'isAbstract: $isAbstract, '
        'isEnum: $isEnum, '
        'isMixin: $isMixin, '
        'constructors: $constructors, '
        'fields: $fields, '
        'methods: $methods, '
        'typeParameters: $typeParameters'
        ')';
  }
}

/// {@template client_class_method_metadata}
/// Metadata about a method of a class (used in [ClientClassMetadata]).
/// {@endtemplate}
class ClientClassMethodMetadata {
  const ClientClassMethodMetadata._({
    required this.name,
    required this.returnType,
    required this.parameters,
    required this.isAbstract,
    required this.isStatic,
    required this.hasOverride,
  });

  /// The name of the method.
  final String name;

  /// The return type of the method.
  final DartType returnType;

  /// The parameters of the method.
  final List<FormalParameterElement> parameters;

  /// Indicates whether the method is abstract.
  final bool isAbstract;

  /// Indicates whether the method is static.
  final bool isStatic;

  /// Indicates whether the method is an override.
  final bool hasOverride;

  @override
  String toString() {
    return 'ClientClassMethodMetadata('
        'name: $name, '
        'returnType: $returnType, '
        'parameters: $parameters, '
        'isAbstract: $isAbstract, '
        'isStatic: $isStatic, '
        'hasOverride: $hasOverride'
        ')';
  }
}

class _DefaultTypeVisitor extends TypeVisitor<void> {
  final _types = <DartType>[];
  DartType? get type => _types.isEmpty ? null : _types.last;

  @override
  void visitDynamicType(DynamicType type) {
    _types.add(type);
  }

  @override
  void visitFunctionType(FunctionType type) {
    _types.add(type);
  }

  @override
  void visitInterfaceType(InterfaceType type) {
    _types.add(type);
  }

  @override
  void visitNeverType(NeverType type) {
    _types.add(type);
  }

  @override
  void visitTypeParameterType(TypeParameterType type) {
    _types.add(type);
  }

  @override
  void visitVoidType(VoidType type) {
    _types.add(type);
  }

  @override
  void visitRecordType(RecordType type) {
    _types.add(type);
  }

  @override
  void visitInvalidType(InvalidType type) {
    _types.add(type);
  }
}
