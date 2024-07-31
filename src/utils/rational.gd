class_name Rational
extends RefCounted
## Represents a rational number (any number that can be represented as a
## fraction, i.e. in the form "a/b", where a and b are integers and b is non-
## zero).
##
## Can be used to perform arithmetic and relational operations on accurate
## fractional values, without the rounding errors or other artifacts generated
## from using floating point values. This is achieved by performing all
## arithmetic operations (outside of to_float()) only with integer operations.
##
## The numerator and denominator each have an operating space of 64 bits (the
## size of Godot's int type). This range should be safe for performing
## operations on 32-bit numerator and denominator values. Operations that occur
## beyond 32-bit bounds may result in undefined behavior.
##
## Always maintains simplest form (numerator and denominator are reduced until
## they have have no common factors).
##
## Note the rational.get_numerator() method returns the absolute value of the
## numerator. The sign can be retrieved with Rational.get_sign(), which returns
## +1, -1, or 0.
##
## pow() and log() functions are not implemented, as their domain and range
## naturally reach beyond the set of rational numbers. If you need these
## operations, you can use a Rational.to_float() value with the standard pow/
## log functions.

var _numerator: int
var _denominator: int

const MAX_FLOAT_PRECISION: int = 14

# helper methods --------------------------------------------------------------

# returns greatest common divisor of two integers
static func _gcd(a: int, b: int) -> int:
	return a if b == 0 else _gcd(b, a % b)

# returns least common multiple of two integers
static func _lcm(a: int, b: int) -> int:
	@warning_ignore("integer_division")
	return a / _gcd(a, b) * b

# constructor -----------------------------------------------------------------

# valid constructor forms:
# Rational.new()
#   Produces 0 / 1 (default value)
# Rational.new(Rational)
#   Produces a copy of Rational
# Rational.new(int)
#   Produces int / 1
# Rational.new(int1, int2)
#   Produces int1 / int2, in simplified form
# Rational.new(float, int)
#   Will convert float to the closest rational number, using int places of
#   precision. May not give desired results due to floating point inaccuracies.
# Rational.new(String)
#   Expected string format: "a/b". Will generate an error when the string is in
#   an invalid format.
# Rational.new(Vector2i)
#   Produces Vector2i.x / Vector2i.y, in simplified form
func _init(a: Variant = 0, b: int = 1) -> void:
	match typeof(a):
		TYPE_INT:
			_numerator = a
			_denominator = b
		TYPE_VECTOR2I:
			_numerator = a.x
			_denominator = a.y
		TYPE_OBJECT when a is Rational:
			_numerator = a._numerator
			_denominator = a._denominator
		TYPE_FLOAT:
			_denominator = 10 ** clampi(b, 1, MAX_FLOAT_PRECISION)
			_numerator = a * _denominator
		TYPE_STRING:
			var tokens = a.split("/")
			assert(tokens.size() == 2 and tokens[0].is_valid_int()
					and tokens[1].is_valid_int(),
					'String must be in the format "numerator/denominator"')
			_numerator = int(tokens[0])
			_denominator = int(tokens[1])
		_:
			assert(false, 'Parser Error: Invalid argument for Rational constructor: Argument "a" must be "int", "float", "Vector2i", "String", or "Rational".')
	_test_for_invalid_number()
	_simplify()


# creates a copy of object (overloads Object.duplicate())
func duplicate() -> Rational:
	return Rational.new(_numerator, _denominator)


# private methods -------------------------------------------------------------

func _test_for_invalid_number() -> void:
	assert(_denominator != 0, "Denominator cannot be zero")


func _simplify() -> void:
	# reduce factors
	var gcd: int = Rational._gcd(_numerator, _denominator)
	_numerator /= gcd
	_denominator /= gcd
	
	# normalize sign
	if _denominator != absi(_denominator):
		_numerator = -_numerator
		_denominator = -_denominator


# returns a string in the format of a proper/improper fraction, "a/b", or as
# a wholw number if it is such
func _to_string() -> String:
	var text: String = str(_numerator)
	if _denominator > 1:
		text += "/" + str(_denominator)
	return text


# public methods --------------------------------------------------------------

# returns a string in the format of a mixed fraction, "a b/c"; fractional part
# won't be printed if it's equal to zero
func to_string_as_mixed() -> String:
	var text: String = str(get_whole_part())
	var frac: Rational = get_fractional_part()
	
	if is_negative():
		text = "-" + text
	if !frac.is_zero():
		text += " " + str(frac)
		
	return text


# returns a float with the specificed precision (up to 14 places)
func to_float(precision: int = MAX_FLOAT_PRECISION) -> float:
	var mask: int = 10 ** clampi(precision, 1, MAX_FLOAT_PRECISION)
	var fraction: float = _numerator / float(_denominator) * mask
	return float(roundi(fraction)) / mask


# returns a signed integer, rounded toward zero
func to_int() -> int:
	return get_sign() * get_whole_part()


# returns numerator (without sign)
func get_numerator() -> int:
	return absi(_numerator)


func get_denominator() -> int:
	return _denominator


func get_sign() -> int:
	return 0 if is_zero() else -1 if is_negative() else +1


# returns whole part of Rational (without sign)
func get_whole_part() -> int:
	@warning_ignore("integer_division")
	return absi(_numerator / _denominator)


# returns fractional part of Rational (without sign)
func get_fractional_part() -> Rational:
	return Rational.new(absi(_numerator) % _denominator, _denominator)


# returns true if Rational is positive
func is_positive() -> bool:
	return _numerator > 0


# returns true if Rational is negative
func is_negative() -> bool:
	return _numerator < 0


# returns true if Rational is zero
func is_zero() -> bool:
	return _numerator == 0


# returns true if Rational is an integer
func is_integer() -> bool:
	return _denominator == 1


# "operator" methods ----------------------------------------------------------

func add(summand: Rational) -> Rational:
	var new_num: int = ((_numerator * summand._denominator)
			+ (summand._numerator * _denominator))
	var new_den: int = _denominator * summand._denominator
	return Rational.new(new_num, new_den)


func subtract(subtrahend: Rational) -> Rational:
	var new_num: int = ((_numerator * subtrahend._denominator)
			- (subtrahend._numerator * _denominator))
	var new_den: int = _denominator * subtrahend._denominator
	return Rational.new(new_num, new_den)


func multiply(factor: Rational) -> Rational:
	var new_num: int = _numerator * factor._numerator
	var new_den: int = _denominator * factor._denominator
	return Rational.new(new_num, new_den)


func divide(divisor: Rational) -> Rational:
	assert(divisor._numerator != 0, "Cannot divide by zero")
	var new_num: int = _numerator * divisor._denominator
	var new_den: int = _denominator * divisor._numerator
	return Rational.new(new_num, new_den)


func negate() -> Rational:
	return Rational.new(-_numerator, _denominator)


func reciprocal() -> Rational:
	assert(_numerator != 0, "Cannot get the reciprocal of zero")
	return Rational.new(_denominator, _numerator)


func abs() -> Rational:
	return Rational.new(absi(_numerator), _denominator)


# rounds Rational up to nearest integer
func ceil() -> Rational:
	var remainder: int = posmod(_numerator, _denominator)
	return (Rational.new(self) if remainder == 0 else
			Rational.new(_numerator + _denominator - remainder, _denominator))


# rounds Rational down to nearest integer
func floor() -> Rational:
	var remainder: int = posmod(_numerator, _denominator)
	return (Rational.new(self) if remainder == 0 else
			Rational.new(_numerator - remainder, _denominator))


# round Rational to nearest integer, rounding 1/2 away from zero
func round() -> Rational:
	var maybe_one: int = (get_sign()
			if get_fractional_part().is_gt_eq(Rational.new(1, 2)) 
			else 0)
	@warning_ignore("integer_division")
	var new_number: int = ((_numerator / _denominator) + maybe_one)
	return Rational.new(new_number)


# limits Rational value to the range [minimum, maximum]
func clamp(minimum: Rational, maximum: Rational) -> Rational:
	if is_lt(minimum):
		return Rational.new(minimum)
	elif is_gt(maximum):
		return Rational.new(maximum)
	else:
		return Rational.new(self)


# wraps Rational value to the range [minimum, maximum)
func wrap(minimum: Rational, maximum: Rational) -> Rational:
	var wrapRange: Rational = maximum.subtract(minimum)
	
	return (self.subtract(wrapRange.multiply((self.subtract(minimum).
			divide(wrapRange)).floor())))


# relational methods ----------------------------------------------------------

func is_eq(right: Rational) -> bool:
	return ((_numerator == right._numerator)
			and (_denominator == right._denominator))


func is_not_eq(right: Rational) -> bool:
	return ((_numerator != right._numerator)
			or (_denominator != right._denominator))


func is_lt(right: Rational) -> bool:
	return (_numerator * right._denominator) < (right._numerator * _denominator)


func is_gt(right: Rational) -> bool:
	return (_numerator * right._denominator) > (right._numerator * _denominator)


func is_lt_eq(right: Rational) -> bool:
	return (_numerator * right._denominator) <= (right._numerator * _denominator)


func is_gt_eq(right: Rational) -> bool:
	return (_numerator * right._denominator) >= (right._numerator * _denominator)


# static methods --------------------------------------------------------------

static func max(values: Array[Rational]) -> Rational:
	return values.reduce(
			func(acc, v) -> Rational: return v if v.is_gt(acc) else acc)


static func min(values: Array[Rational]) -> Rational:
	return values.reduce(
			func(acc, v) -> Rational: return v if v.is_lt(acc) else acc)


# passed array gets modified by sort
static func sort(values: Array[Rational], is_descending: bool = false) -> void:
	values.sort_custom(
			func(a, b): return a.is_gt(b) if is_descending else a.is_lt(b))


