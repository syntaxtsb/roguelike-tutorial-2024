extends Node


func _ready():
	var r := Rational.new(5, 3)
	print(Rational.new())
	print(Rational.new(42))
	print(Rational.new(2, 7))
	print(Rational.new(r))
	print(Rational.new(PI))
	print(Rational.new(PI, 5))
	print(Rational.new("27/8"))
	#print(Rational.new("foo")) # error
	print(Rational.new(Vector2i(8, 3)))
	print()
	
	var f: Array[Rational] = []
	for i in 5:
		f.append(Rational.new(randi_range(-10, 10),randi_range(1, 10)))
	print(f)
	print("min: ", Rational.min(f))
	print("max: ", Rational.max(f))
	Rational.sort(f, true)
	print("desc: ", f)
	Rational.sort(f)
	print("asc: ", f)
	print()
	print("clamp: ", f[0].clamp(f[1], f[2]))
	print("wrap: ", f[0].wrap(f[1], f[2]))
	print("mod: ", 8 % 3, (-8) % 3)
	print()
	
	for i in 5:
		var x := Rational.new(randi_range(-10, 10),randi_range(1, 10))
		var y := Rational.new(randi_range(-10, 10),randi_range(1, 10))
		print(str(x) + " " + str(y))
		print("is_lt " + str(x.is_lt(y)))
		print("add: " + str(x.add(y)) + " " + str(x.add(y).to_float()))
		print("sub: " + str(x.subtract(y)))
		print("mult: " + str(x.multiply(y)))
		print("div: " + str(x.divide(y)))
		print(" ".join([x,x.floor(),x.ceil()]))
	
	print(" ".join(["x","round"]))
	for i in 20:
		var x := Rational.new(-8 + i, 4)
		print(" ".join([x, x.round()]))
