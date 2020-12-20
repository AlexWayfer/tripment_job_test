# frozen_string_literal: true

require_relative '../../lib/medical_procedures_client'

RSpec.describe MedicalProceduresClient do
  subject { described_class.new }

  describe '#query' do
    subject { super().query }

    let(:expected_output) do
      {
        'Propaedeutic' => include(
          'Medical inspection (body features)',
          'Palpation',
          'Percussion',
          <<~TEXT.chomp
            Vital signs measurement, such as blood pressure, body temperature, or pulse (or heart rate)
          TEXT
        ),
        'Diagnostic' => include(
          {
            'Lab tests' => include(
              'Biopsy test',
              'Urinalysis'
            )
          },
          'Electrocardiography',
          {
            'Endoscopy' => include(
              'Colonoscopy',
              'Gastroscopy'
            )
          },
          'Magnetoencephalography',
          {
            'Medical imaging' => include(
              {
                'Angiography' => include(
                  'Aortography',
                  'Coronary angiography',
                  'Ventriculography'
                )
              },
              'Computed tomography',
              'Fluoroscopy',
              {
                'Magnetic resonance imaging' => include(
                  'Diffuse optical imaging',
                  'Diffusion-weighted imaging'
                )
              },
              'Radiography',
              {
                'Ultrasonography' => include(
                  'Contrast-enhanced ultrasound',
                  'Intravascular ultrasound'
                )
              },
              'Virtual colonoscopy'
            )
          },
          'Posturography'
        ),
        'Therapeutic' => include(
          'Hemodialysis',
          'Extracorporeal membrane oxygenation (ECMO)',
          'Physical therapy/Physiotherapy',
          {
            'Shock therapy' => include(
              'Insulin shock therapy',
              'Symptomatic treatment'
            )
          },
          'Transcutaneous electrical nerve stimulation (TENS)',
          'Animal-Assisted Therapy'
        ),
        'Surgical' => include(
          'Amputation',
          'Cardiopulmonary resuscitation (CPR)',
          'Image-guided surgery'
        ),
        'Anesthesia' => include(
          'Dissociative anesthesia',
          'General anesthesia',
          {
            'Local anesthesia' => include(
              'Topical anesthesia (surface)',
              'Epidural (extradural) block',
              'Spinal anesthesia (subarachnoid block)'
            )
          },
          'Regional anesthesia'
        ),
        'Other' => include(
          'Interventional radiology',
          'Screening'
        )
      }
    end

    it { is_expected.to match expected_output }
  end
end
