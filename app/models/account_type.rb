class AccountType < ActiveRecord::Base
  self.table_name = 'account_types'

  CODE_OF_MULTI = 'MULTI'

  def type_multi?
    self.code == CODE_OF_MULTI
  end
end
