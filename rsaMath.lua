local rsa = {}
local extended_gcd, gcd, decompose, isComposite, isPrime, randomPrime
extended_gcd = function(a, b)
	if b == 0 then
		return a, 1, 0
	else
		local d2, x2, y2 = extended_gcd(b, a % b)
		d, x, y = d2, y2, x2 - (a // b) * y2
		return d, x, y
	end
end
gcd = function(a, b)
	if b == 0 then
		return a
	else
		return gcd(b, a % b)
	end
end
decompose = function(n)
	local i = 0
	while n & (1 << i) == 0 do
		i = i + 1
		return i, n >> i
	end
end
isComposite = function(a, n)
	t,d = decompose(n - 1)
	x = a^d%n
	if x == 1 or x == n - 1 then
		return False
	end
	for i=1, t do
		x0 = x
		x = x0^2%n
		if x == 1 and x0 ~= 1 and x0 ~= n - 1 then
			return true
		end
	end
	if x ~= 1 then
		return true
	end
	return false
end
isPrime = function(n)
	if n%2 == 0 then
		return false
	end
	for i=1, 40 do
		a = math.random(n - 1)
		if isComposite(a, n) then
			return false
		end
	end
	return true
end
rsa.generateKeys = function(p, q)
	local product = bint(p*q)
	local public
	local totient = (p - 1) * (q - 1)
	for i=math.floor(math.sqrt(totient)), totient - 1 do
		if gcd(totient, i) == 1 and isPrime(i) then
			public = i
			break
		end
	end
	local _, private, _ = extended_gcd(public, totient)
	return product, public, private % totient, totient
end
rsa.encryption = function(data, key, modulo)
	return data^key%modulo
end
return rsa
