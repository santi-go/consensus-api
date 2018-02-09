require_relative '../system/json_validator.rb'



describe 'JSON validator' do

  it 'checks that all required fields to create proposal are present' do
    body = {      'proposer': 'consensus@consensus.com',
                  'circle': ['involved@involved.es'],
                  'proposal': 'A proposal'}

    expect(JSONValidator.validate_create_proposal?(body)).to eq(true)
  end

  it 'checks that json needs proposer field' do
    body = {      'circle': ['involved@involved.es'],
                  'proposal': 'A proposal'}

    expect(JSONValidator.validate_create_proposal?(body)).to eq(false)
  end

  it 'checks that json needs circle field' do
    body = {      'proposer': 'consensus@consensus.com',
                  'proposal': 'A proposal'}

    expect(JSONValidator.validate_create_proposal?(body)).to eq(false)
  end

  it 'checks that json needs proposal field' do
    body = {      'proposer': 'consensus@consensus.com',
                  'circle': ['involved@involved.es'],}

    expect(JSONValidator.validate_create_proposal?(body)).to eq(false)
  end

  it 'checks that the json fields are not empty' do
    body = {      'proposer': 'consensus@consensus.com',
                  'circle': ['involved@involved.es'],
                  'proposal': 'A proposal'}

    expect(JSONValidator.validate_create_proposal?(body)).to eq(true)
  end

  it 'fails if proposer is empty' do
    body = {      'proposer': '',
                  'circle': ['involved@involved.es'],
                  'proposal': 'A proposal'}

    expect(JSONValidator.validate_create_proposal?(body)).to eq(false)
  end

  it 'fails if circle is empty' do
    body = {      'proposer': 'consensus@consensus.com',
                  'circle': [],
                  'proposal': 'A proposal'}

    expect(JSONValidator.validate_create_proposal?(body)).to eq(false)
  end

  it 'fails if proposal is empty' do
    body = {      'proposer': 'consensus@consensus.com',
                  'circle': ['involved@involved.es'],
                  'proposal': ''}

    expect(JSONValidator.validate_create_proposal?(body)).to eq(false)
  end

end
