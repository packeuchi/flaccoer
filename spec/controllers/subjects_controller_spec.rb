require 'rails_helper'

describe SubjectsController, 'ログイン前' do
  it_behaves_like 'a protected base controller for new'
end

describe SubjectsController, '会計年度選択前' do
  it_behaves_like 'a protected with fiscal base controller for new'
end

describe SubjectsController, 'ログイン・会計年度選択後' do
  let(:current_user) { create(:user) }
  let(:account_type) { AccountType.find(1) }
  let(:subject_template_type) { FactoryGirl.create(:subject_template_type, account_type: account_type) }
  let(:fiscal_year) {
    FactoryGirl.create(:fiscal_year, subject_template_type: subject_template_type, user: current_user)
  }
  let(:journal_date) { Date.new(2015, 4, 1) }
  let(:subject_types) { SubjectType.where(account_type_id: 1) }

  let(:params_hash) { attributes_for(:fiscal_year) }
  let(:subject_params_hash) {
    attributes_for(:subject).tap { |h|
      h[:subject_template_type] = subject_template_type
      h[:subject_type_id] = subject_types.first.id
    }
  }

  # 事前認証とタイムアウトチェックが通るようにしておきます。
  before do
    session[:user_id] = current_user.id
    session[:last_access_time] = 1.second.ago
    session[:fiscal_year_id] = fiscal_year.id
    session[:journal_date] = journal_date
  end

  describe '#edit_all' do
    example 'assign fiscal_year' do
      get :edit_all
      expect(assigns(:fiscal_year)).to eq(fiscal_year)
    end
  end

  describe '#update_all' do
    example 'indexにリダイレクト' do
      expect(SubjectsService).to receive(:cleanup_subjects).with(fiscal_year)
      expect(SubjectsCacheService).to receive(:clear_subjects_cache).with(fiscal_year)

      post :update_all, fiscal_year: params_hash
      expect(response).to redirect_to(subjects_url)
    end
  end

  describe '#new' do
    example 'subjectを設定' do
      get :new
      expect(assigns(:subject)).to have_attributes(fiscal_year: fiscal_year)
      expect(assigns(:subject_types)).to eq(subject_types)
    end
  end

  describe '#create' do
    example 'indexにリダイレクト' do
      expect(SubjectsCacheService).to receive(:clear_subjects_cache).with(fiscal_year)

      post :create, subject: subject_params_hash
      expect(response).to redirect_to(subjects_url)
      expect(assigns(:subject_types)).to eq(subject_types)
    end
  end

  xdescribe '#destroy' do
    # TODO: 実装(deleteメソッドに対するidの渡し方が分からない)
  end
end
