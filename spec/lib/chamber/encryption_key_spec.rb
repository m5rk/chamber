# frozen_string_literal: true

require 'rspectacular'
require 'chamber/encryption_key'

module    Chamber
describe  EncryptionKey do
  it 'can find default keys by reading files' do
    key = EncryptionKey.resolve(rootpath:   'spec/fixtures/keys/',
                                namespaces: [],
                                filenames:  'spec/fixtures/keys/.chamber.pub.pem')

    expect(key).to eql(default: "default public key\n")
  end

  it 'can find default keys by reading the environment' do
    ENV['CHAMBER_PUBLIC_KEY'] = 'environment public key'

    key = EncryptionKey.resolve(rootpath:   'spec/fixtures/keys/',
                                namespaces: [],
                                filenames:  'spec/fixtures/.chamber.pub.pem')

    expect(key).to eql(default: 'environment public key')

    ENV.delete('CHAMBER_PUBLIC_KEY')
  end

  it 'can find namespaced key files by reading files' do
    key = EncryptionKey.resolve(rootpath:   'spec/fixtures/keys/',
                                namespaces: [],
                                filenames:  'spec/fixtures/keys/.chamber.development.pub.pem')

    expect(key).to eql(development: "development public key\n")
  end

  it 'can find namespaced key files by reading the environment' do
    ENV['CHAMBER_DEVELOPMENT_PUBLIC_KEY'] = 'environment public key'

    key = EncryptionKey.resolve(rootpath:   'spec/fixtures/keys/',
                                namespaces: [],
                                filenames:  'spec/fixtures/.chamber.development.pub.pem')

    expect(key).to eql(development: 'environment public key')

    ENV.delete('CHAMBER_DEVELOPMENT_PUBLIC_KEY')
  end

  it 'can generate generic key filenames from namespaces' do
    key = EncryptionKey.resolve(rootpath:   'spec/fixtures/keys/',
                                namespaces: %w{test production},
                                filenames:  %w{
                                              spec/fixtures/keys/.chamber.development.pub.pem
                                            })

    expect(key).to eql(
                     development: "development public key\n",
                     test:        "test public key\n",
                     production:  "production public key\n",
                   )
  end

  it 'can lookup generic key from namespaces by reading the environment' do
    ENV['CHAMBER_MISSING_PUBLIC_KEY'] = 'environment public key'

    key = EncryptionKey.resolve(rootpath:   'spec/fixtures/keys/',
                                namespaces: %w{test missing production},
                                filenames:  [])

    expect(key).to eql(
                     missing:    'environment public key',
                     production: "production public key\n",
                     test:       "test public key\n",
                   )

    ENV.delete('CHAMBER_MISSING_PUBLIC_KEY')
  end

  it 'removes duplicates from the filenames and namespaces if necessary' do
    key = EncryptionKey.resolve(rootpath:   'spec/fixtures/keys/',
                                namespaces: %w{test production},
                                filenames:  %w{
                                              spec/fixtures/keys/.chamber.development.pub.pem
                                              spec/fixtures/keys/.chamber.test.pub.pem
                                            })

    expect(key).to eql(
                     development: "development public key\n",
                     test:        "test public key\n",
                     production:  "production public key\n",
                   )
  end

  it 'can find multiple keys' do
    key = EncryptionKey.resolve(
            rootpath:   'spec/fixtures/keys/',
            namespaces: [],
            filenames:  [
                          'spec/fixtures/keys/.chamber.development.pub.pem',
                          'spec/fixtures/keys/.chamber.pub.pem',
                          'spec/fixtures/keys/.chamber.production.pub.pem',
                          'spec/fixtures/keys/.chamber.test.pub.pem',
                        ],
          )

    expect(key).to eql(
                        default:     "default public key\n",
                        development: "development public key\n",
                        production:  "production public key\n",
                        test:        "test public key\n",
                      )
  end

  it 'raises an error if the key cannot be found' do
    expect {
      EncryptionKey.resolve(rootpath:   'spec/fixtures/keys/',
                            namespaces: [],
                            filenames:  'spec/fixtures/keys/.chamber.staging.pub.pem')
    }.to \
      raise_error(ArgumentError).
        with_message('One or more of your keys were not found: ' \
                     'spec/fixtures/keys/.chamber.staging.pub.pem')
  end
end
end
