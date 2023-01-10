$DEBUG
OPTION _EXPLICIT

_TITLE "QB64pe Morphing"
SCREEN _NEWIMAGE(800, 600, 32)

DIM image AS LONG

image = _LOADIMAGE("./assets/peLogo.png")

CONST TESSELATION = 1 '                             How far we're going to break the cube's faces down - the higher the breakdown the more vertices and textures and the better the sphere
CONST CUBESIZE = 100 '                              The cube is of dimensions CUBESIZE x CVUBESIZE x CUBESIZE
CONST SPHERERADIUS = SQR(3 * (CUBESIZE / 2) ^ 2) '  Make it so the corners of the cube lie on the surface of the sphere

TYPE POINT3 '                                       A type that holds a 3D coordinate for each vertex
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

TYPE ANGLE3 '                                       A type that holds a 3D coordinate for each vertex
    x AS SINGLE
    y AS SINGLE
    z AS SINGLE
END TYPE

TYPE TEXTUREUV '                                    A type to hold texture coordinates for each vertex
    u AS SINGLE
    v AS SINGLE
END TYPE

TYPE TRIANGLE '                                     A type that holds three vertex indexes to make up a triangle
    p1 AS INTEGER
    p2 AS INTEGER
    p3 AS INTEGER
END TYPE

DIM cubeVertices((TESSELATION + 1) ^ 2 * 6) AS POINT3
DIM sphereVertices((TESSELATION + 1) ^ 2 * 6) AS POINT3
DIM uvs((TESSELATION + 1) ^ 2 * 6) AS TEXTUREUV
DIM triangles(TESSELATION ^ 2 * 2 * 6) AS TRIANGLE

CLS
CreateShapes
DrawShape
_DISPLAY
END

SUB CreateShapes

    SHARED cubeVertices() AS POINT3
    SHARED sphereVertices() AS POINT3
    SHARED uvs() AS TEXTUREUV
    SHARED image AS LONG
    SHARED triangles() AS TRIANGLE

    DIM v AS INTEGER
    DIM i AS INTEGER
    DIM j AS INTEGER
    DIM r AS SINGLE
    DIM t AS INTEGER

    v = 0
    t = 0

    FOR i = 0 TO TESSELATION
        FOR j = 0 TO TESSELATION
            cubeVertices(v).x = -CUBESIZE / 2 + CUBESIZE * i / TESSELATION
            cubeVertices(v).y = CUBESIZE / 2 - CUBESIZE * j / TESSELATION
            cubeVertices(v).z = CUBESIZE / 2
            r = SPHERERADIUS * SQR(cubeVertices(v).x ^ 2 + cubeVertices(v).y ^ 2 + cubeVertices(v).z ^ 2) / (CUBESIZE / 2)
            sphereVertices(v).x = cubeVertices(v).x * r
            sphereVertices(v).y = cubeVertices(v).y * r
            sphereVertices(v).z = cubeVertices(v).z * r
            uvs(v).u = _WIDTH(image) * i / TESSELATION
            uvs(v).v = _HEIGHT(image) - _HEIGHT(image) * j / TESSELATION
            IF i < TESSELATION AND j < TESSELATION THEN
                triangles(t).p1 = v
                triangles(t).p2 = v + 1
                triangles(t).p3 = v + TESSELATION + 1
                t = t + 1
                triangles(t).p1 = v + 1
                triangles(t).p2 = v + TESSELATION + 2
                triangles(t).p3 = v + TESSELATION + 1
                t = t + 1
            END IF
            v = v + 1
        NEXT j
    NEXT i

END SUB

SUB Rotate3 (p AS POINT3, a AS ANGLE3, rotatedPoint AS POINT3)
    DIM px AS POINT3 '                                              p rotated about x axis
    DIM py AS POINT3 '                                              px rotated about y axis
    DIM pz AS POINT3 '                                              py rotated about z axis

    px.x = p.x
    px.y = p.y * COS(a.x) - p.z * SIN(a.x)
    px.z = p.y * SIN(a.x) + p.z * COS(a.x)

    py.x = px.x * COS(a.y) + px.z * SIN(a.y)
    py.y = px.y
    py.z = px.z * COS(a.y) - px.x * SIN(a.y)

    pz.x = py.x * COS(a.z) - py.y * SIN(a.z)
    pz.y = py.x * SIN(a.z) + py.y * COS(a.z)
    pz.z = py.z

    rotatedPoint = pz
END SUB

SUB RotateShape
END SUB

SUB DrawShape

    SHARED triangles() AS TRIANGLE
    SHARED image AS LONG
    SHARED uvs() AS TEXTUREUV
    SHARED cubeVertices() AS POINT3

    DIM i AS INTEGER
    DIM p1 AS INTEGER
    DIM p2 AS INTEGER
    DIM p3 AS INTEGER

    FOR i = 0 TO 1 ' UBOUND(triangles) - 1
        p1 = triangles(i).p1
        p2 = triangles(i).p2
        p3 = triangles(i).p3
        _MAPTRIANGLE _CLOCKWISE (uvs(p1).u, uvs(p1).v)-(uvs(p2).u, uvs(p2).v)-(uvs(p3).u, uvs(p3).v), image TO(400 + cubeVertices(p1).x, 300 + cubeVertices(p1).y)-(400 + cubeVertices(p2).x, 300 + cubeVertices(p2).y)-(400 + cubeVertices(p3).x, 300 + cubeVertices(p3).y)
        PRINT uvs(p1).u; ", "; uvs(p1).v; " - "; uvs(p2).u; ", "; uvs(p2).v; " - "; uvs(p3).u; ", "; uvs(p3).v
        PRINT 400 + cubeVertices(p1).x; ", "; 300 + cubeVertices(p1).y; " - "; 400 + cubeVertices(p2).x; ", "; 300 + cubeVertices(p2).y; " - "; 400 + cubeVertices(p3).x; ", "; 300 + cubeVertices(p3).y
    NEXT i

END SUB


