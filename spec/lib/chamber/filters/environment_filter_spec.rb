# frozen_string_literal: true
require 'rspectacular'
require 'chamber/filters/environment_filter'

module    Chamber
module    Filters
describe  EnvironmentFilter do
  it 'can extract data from the environment if an existing variable matches the ' \
     'composite key' do

    ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING'] = 'value 2'

    filtered_data = EnvironmentFilter.execute(data: {
                                                test_setting_group: {
                                                  test_setting_level: {
                                                    test_setting: 'value 1',
                                                  },
                                                },
                                              })

    test_setting  = filtered_data.test_setting_group.test_setting_level.test_setting

    expect(test_setting).to eql 'value 2'

    ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING')
  end

  it 'does not affect items which are not stored in the environment' do
    ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING'] = 'value 2'

    filtered_data = EnvironmentFilter.execute(data: {
                                                test_setting_group: {
                                                  test_setting_level: {
                                                    test_setting:    'value 1',
                                                    another_setting: 'value 3',
                                                  },
                                                },
                                              })

    another_setting = filtered_data.test_setting_group.test_setting_level.another_setting

    expect(another_setting).to eql 'value 3'

    ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING')
  end

  it 'can extract an integer from the environment if an existing variable' \
     'matches the composite key' do

    ENV['TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING'] = '2'

    filtered_data = EnvironmentFilter.execute(data: {
                                                test_setting_group: {
                                                  test_setting_level: {
                                                    test_setting: 1,
                                                  },
                                                },
                                              })

    test_setting  = filtered_data.test_setting_group.test_setting_level.test_setting

    expect(test_setting).to eql 2

    ENV.delete('TEST_SETTING_GROUP_TEST_SETTING_LEVEL_TEST_SETTING')
  end
end
end
end
