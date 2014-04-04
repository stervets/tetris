Application.startTest =
    'Application.matrixEmpty()': ->
        width = 10
        height = 20
        a = Application.matrixEmpty(width, height)
        ok _.isArray(a), 'Got array'
        equal a.length, height, 'Height check'
        ok _.isArray(a[0]), 'Width array'
        equal a[0].length, width, 'Width check'

    'Application.lineCopy()': ->
        a = [0,1,1,0]
        b = Application.lineCopy(a)
        ok _.isArray(b), 'Line copy is array'
        equal a.length, b.length, "Length check"
        b[0] = 1
        notEqual a[0], b[0], 'Second array is a copy'
        c = Application.lineCopy(b, 2)
        ok c[0]==2, "Value change check"
        ok c[3]==0, "Value not change check"

    'Application.matrixCopy()': ->
        a = Application.matrixEmpty(10, 10)
        b = Application.matrixCopy(a)
        ok _.isArray(b), 'Got array'
        ok _.isArray(b[0]), 'Width array'
        b[0][0] = 1
        notEqual b[0][0], a[0][0], 'Second array is a copy'

        c = Application.matrixCopy(b, 2)
        ok c[0][0]==2, "Value change check"
        ok c[0][1]==0, "Value not change check"


Application.runTest = {

}

