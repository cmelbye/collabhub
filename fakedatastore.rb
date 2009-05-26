# Stub class that you can use when you don't have a Tokyo Tyrant server.
class FakeDataStore
  def []=(pk, data)
  end
  
  def query
    []
  end
  
  def genuid
    1
  end
end