require_relative('../system/subject')

describe 'Subject' do
  it 'has first six words of the proposal' do
    proposal = "En mi opinion deberiamos de crear una funcion que determine el uso del mail"

    expect(Subject.create(proposal)).to eq("En mi opinion deberiamos de crear...")
  end

  it ' finished when the sentence finds a dot, <br>, or </p> tag and has a maximum of six words' do
    plain_proposal = "La propuesta esta creada. Consiste en esto."
    proposal_with_break_line = "La propuesta esta creada<br>"
    proposal_html = "<p>propuesta</p><p></p><p>con br y p<br> Consiste en esto<p>"

    expect(Subject.create(plain_proposal)).to eq("La propuesta esta creada.")
    expect(Subject.create(proposal_with_break_line)).to eq("La propuesta esta creada")
    expect(Subject.create(proposal_html)).to eq("propuesta con br y p Consiste...")
  end

  it 'started with a <br> results in error' do
    proposal_with_initial_br = "        <br>     <br><br> <br><br><br><br><br> propuesta<p></p><p>con br y p<br> Consiste en esto<p>"

    expect(Subject.create(proposal_with_initial_br)).to eq("propuesta con br y p Consiste...")
  end
end
