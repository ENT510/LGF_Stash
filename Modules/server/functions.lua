SvFunctions = {}

function SvFunctions.generateUniqueStashId()
    local stashId, exists
    repeat
        local uniqueID = Utility.string:RandStr(5, 'aln')
        stashId = ("safe_%s"):format(uniqueID)
        exists = MySQL.scalar.await('SELECT 1 FROM lgf_stashData WHERE stash_id = ? LIMIT 1', { stashId })
    until not exists

    return stashId
end

