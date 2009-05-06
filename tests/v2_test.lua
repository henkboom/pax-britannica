require "dokidoki.module" [[]]

v2 = require "dokidoki.v2"

assert(v2.zero.x == 0);
assert(v2.zero.y == 0);
assert(v2.i.x == 1);
assert(v2.i.y == 0);
assert(v2.j.x == 0);
assert(v2.j.y == 1);

assert(v2(1, 2) == v2(1, 2))
assert(v2(1, 2) ~= v2(10, 20))
assert(v2(1, 2) + v2(10, 20) == v2(11, 22))
assert(v2(1, 2) - v2(10, 20) == v2(-9, -18))
assert(-v2(1, 2) == v2(-1, -2))
assert(v2.i - v2.j == -v2(-1, 1))
assert(v2(1, 2) * 2 == v2(2, 4))
assert(v2(1, 2) / 2 == v2(0.5, 1))
assert(v2.dot(v2.i, v2.i) == 1)
assert(v2.dot(v2.i, -v2.i) == -1)
assert(v2.dot(v2.j, v2.j) == 1)
assert(v2.dot(v2.i, v2.j) == 0)
assert(v2.dot(v2(1, 2), v2(10, 20)) == 50)
assert(v2.dot(v2.i, v2.zero) == 0)
assert(v2.cross(v2.i, v2.i) == 0)
assert(v2.cross(v2.i, v2.zero) == 0)
assert(v2.cross(v2.j, v2.j) == 0)
assert(v2.cross(v2.i, v2.j) == 1)
assert(v2.cross(v2.i, v2.j * 2) == 2)
assert(v2.mag(v2.i) == 1)
assert(v2.mag(v2.zero) == 0)
assert(v2.mag(v2(3, 4)) == 5)
assert(v2.sqrmag(v2(3, 4)) == 25)
