--os.execute("wget -q https://raw.githubusercontent.com/edubart/lua-bint/master/bint.lua")
--remove line 57 if you don't have a data card installed keep it otherwise

local bint = require("bint")(65536)
local comp = require("component")

local rsa = {}
local function extended_gcd(a, b)
	if b == 0 then
		return a, 1, 0
	else
		local d2, x2, y2 = extended_gcd(b, a % b)
		d, x, y = d2, y2, x2 - (a // b) * y2
		return d, x, y
	end
end
local function gcd(a, b)
	if b == 0 then
		return a
	else
		return gcd(b, a % b)
	end
end

local primes = {}

local function isPrime(n)
  local cached = primes[n]
  if cached ~= nil then
    return cached
  end
  for i = 2, math.sqrt(n) do
    if n % i == 0 then
      primes[n] = false
      return false
    end
  end
  primes[n] = true
  return true 
end

local function primeFactorization(n)
  local finale = {}
  local newNumber = n
  for i = 2, n do
    if isPrime(i) then
      while newNumber % i == 0 do 
        finale[#finale + 1] = i
        newNumber = newNumber / i
      end
    end
  end
  return table.concat(finale, ", ")
end

local function randomPrime(min, max)
	math.randomseed(string.gsub(comp.data.random(32), ".", string.byte)) -- remove this if you don't have a data card installed
	while true do
		local num = math.random(min, max)
		if isPrime(num) then
			return num
		end
	end
end
rsa.randomKeys = function(min, max)
	min = min or 2^32
	max = max or min * 1000
	local p = randomPrime(math.ceil(math.sqrt(min)), math.ceil(math.sqrt(max)))
	local q = randomPrime(math.ceil(math.sqrt(min)), math.ceil(math.sqrt(max)))
	return rsa.generateKeys(p, q)
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
	return product, public, private % totient
end
rsa.encryption = function(data, key, modulo) --modulo should be the product
	return bint.upowmod(data, key, modulo)
end
return rsa
