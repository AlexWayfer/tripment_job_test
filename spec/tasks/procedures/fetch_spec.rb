# frozen_string_literal: true

require 'tasks/spec_helper'

describe Rake::Task['procedures:fetch'] do
  before do
    category = Category.create(name: 'Foo')

    root_procedure = Procedure.create(name: 'Bar', parent: category)

    Procedure.create(name: 'Baz', parent: root_procedure)
    Procedure.create(name: 'Qux', parent: root_procedure)

    next unless invoke

    described_class.reenable
    ## Using internally
    Rake::Task['procedures:erase'].reenable
    described_class.invoke
  end

  after do
    system 'rake procedures:erase'
  end

  context 'without invocation' do
    let(:invoke) { false }

    describe 'categories' do
      subject { Category.all }

      it { is_expected.to match_array have_attributes(name: 'Foo') }
    end

    describe 'procedures' do
      subject { Procedure.all }

      let(:expected_procedures) do
        [
          have_attributes(name: 'Bar', parent: have_attributes(name: 'Foo')),
          have_attributes(name: 'Baz', parent: have_attributes(name: 'Bar')),
          have_attributes(name: 'Qux', parent: have_attributes(name: 'Bar'))
        ]
      end

      it { is_expected.to match_array expected_procedures }
    end
  end

  context 'with invocation' do
    let(:invoke) { true }

    describe 'categories' do
      subject { Category.all }

      it { is_expected.not_to include have_attributes(name: 'Foo') }
    end

    describe 'procedures' do
      subject { Procedure.all }

      let(:existed_procedures) do
        [
          have_attributes(name: 'Bar', parent: have_attributes(name: 'Foo')),
          have_attributes(name: 'Baz', parent: have_attributes(name: 'Bar')),
          have_attributes(name: 'Qux', parent: have_attributes(name: 'Bar'))
        ]
      end

      let(:expected_procedures) do
        [
          have_attributes(
            name: 'Medical inspection (body features)',
            parent: have_attributes(name: 'Propaedeutic')
          ),
          have_attributes(
            name: 'Percussion',
            parent: have_attributes(name: 'Propaedeutic')
          ),
          have_attributes(
            name: <<~TEXT.chomp,
              Vital signs measurement, such as blood pressure, body temperature, or pulse (or heart rate)
            TEXT
            parent: have_attributes(name: 'Propaedeutic')
          ),
          have_attributes(
            name: 'Lab tests',
            parent: have_attributes(name: 'Diagnostic')
          ),
          have_attributes(
            name: 'Biopsy test',
            parent: have_attributes(name: 'Lab tests')
          ),
          have_attributes(
            name: 'Electrocardiography',
            parent: have_attributes(name: 'Diagnostic')
          ),
          have_attributes(
            name: 'Endoscopy',
            parent: have_attributes(name: 'Diagnostic')
          ),
          have_attributes(
            name: 'Colonoscopy',
            parent: have_attributes(name: 'Endoscopy')
          ),
          have_attributes(
            name: 'Magnetoencephalography',
            parent: have_attributes(name: 'Diagnostic')
          ),
          have_attributes(
            name: 'Medical imaging',
            parent: have_attributes(name: 'Diagnostic')
          ),
          have_attributes(
            name: 'Angiography',
            parent: have_attributes(name: 'Medical imaging')
          ),
          have_attributes(
            name: 'Coronary angiography',
            parent: have_attributes(name: 'Angiography')
          ),
          have_attributes(
            name: 'Computed tomography',
            parent: have_attributes(name: 'Medical imaging')
          ),
          have_attributes(
            name: 'Magnetic resonance imaging',
            parent: have_attributes(name: 'Medical imaging')
          ),
          have_attributes(
            name: 'Diffusion-weighted imaging',
            parent: have_attributes(name: 'Magnetic resonance imaging')
          ),
          have_attributes(
            name: 'Extracorporeal membrane oxygenation (ECMO)',
            parent: have_attributes(name: 'Therapeutic')
          ),
          have_attributes(
            name: 'Shock therapy',
            parent: have_attributes(name: 'Therapeutic')
          ),
          have_attributes(
            name: 'Symptomatic treatment',
            parent: have_attributes(name: 'Shock therapy')
          ),
          have_attributes(
            name: 'Cardiopulmonary resuscitation (CPR)',
            parent: have_attributes(name: 'Surgical')
          ),
          have_attributes(
            name: 'General anesthesia',
            parent: have_attributes(name: 'Anesthesia')
          ),
          have_attributes(
            name: 'Local anesthesia',
            parent: have_attributes(name: 'Anesthesia')
          ),
          have_attributes(
            name: 'Spinal anesthesia (subarachnoid block)',
            parent: have_attributes(name: 'Local anesthesia')
          ),
          have_attributes(
            name: 'Screening',
            parent: have_attributes(name: 'Other')
          )
        ]
      end

      it { is_expected.not_to include(*existed_procedures) }

      it { is_expected.to include(*expected_procedures) }
    end
  end
end
