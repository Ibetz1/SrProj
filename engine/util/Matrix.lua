local mat = {}

function mat:zero()
    for i = 1,#self do
        self[i][1], self[i][2] = 0, 0
    end
end

function mat:convertIndex(i)
    return self[i], self[i + 1]
end

function mat:map(mat2, indeces)
    for i = 1, #indeces do
        self[i][1] = mat2[indeces[i]][1]
        self[i][2] = mat2[indeces[i]][2]
    end
end

function mat:__add(t)
    for i = 1, #self do
        self[i][1], self[i][2] = self[i][1] + t[1], self[i][2] + t[2]
    end

    return self
end

function mat:__call(t)
    return setmetatable(t, self)
end

mat.__index = mat
setmetatable(mat, mat)

return mat