module ExampleApp

  def ExampleApp.reset(command)
    p "called reset"
    a = AIOUTContinuous.first(:name=>"volume")
    if (a)
      a.data=0
      a.save
    end
  end
end