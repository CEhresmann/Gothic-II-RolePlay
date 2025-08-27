
class Grid {
    chunks = {};
    radius = 1000;

    function getIndex(x, z)
    {
        return {
            x = (x / radius).tointeger(),
            z = (z / radius).tointeger(),
        }
    }

    function find(x, z)
    {
        x = (x / radius).tointeger();
        z = (z / radius).tointeger();
        local index = makeIndex(x,z);

        if (!(index in chunks))
            chunks[index] <- Chunk();

        return chunks[index];
    }

    function getChunk(index)
    {
        if (!(index in chunks))
            chunks[index] <- Chunk();

        return chunks[index];        
    }

    function getLocationChunk(_chunk)
    {
        foreach(chunkIndex, _zchunk in chunks)
        {
            if(_chunk != _zchunk)
                continue;

            local pos = split(chunkIndex, ",")
            return {
                x = pos[0].tointeger(),
                z = pos[1].tointeger(),
            }
        }
    }

    function makeIndex(x,z)
    {
        return x+","+z;
    }
    
    function nearest(_chunk, _radius)
    {
        local nereastChunks = []
        local chunk = Grid.getLocationChunk(_chunk)
        
        for (local x = chunk.x - _radius, endX = chunk.x + _radius; x <= endX; ++x)
        {
            for (local z = chunk.z - _radius, endZ = chunk.z + _radius; z <= endZ; ++z)
            {
                nereastChunks.push(getChunk(makeIndex(x, z)))
            }
        }

        return nereastChunks;
    }
}