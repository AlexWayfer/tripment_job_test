# frozen_string_literal: true

require_relative '../../lib/medical_procedures_client'

RSpec.describe MedicalProceduresClient do
  subject { described_class.new }

  describe '#query' do
    subject { super().query }

    # rubocop:disbale Style/WordArray
    let(:expected_output) do
      {
        'Propaedeutic' => [
          'Medical inspection',
          'Palpation',
          'Vital signs'
        ],
        'Diagnostic' => [
          {
            'Lab test' => [
              'Biopsy test',
              'Urinalysis'
            ]
          },
          'Electrocardiography',
          {
            'Endoscopy' => [
              'Colonoscopy',
              'Gastroscopy'
            ]
          },
          'Magnetoencephalography',
          {
            'Medical imaging' => [
              {
                'Angiography' => [
                  'Aortography',
                  'Coronary angiography',
                  'Ventriculography'
                ]
              },
              'Computed tomography',
              'Fluoroscopy',
              {
                'Magnetic resonance imaging' => [
                  'Diffuse optical imaging',
                  'Diffusion-weighted imaging'
                ]
              },
              'Radiography',
              {
                'Ultrasonography' => [
                  'Contrast-enhanced ultrasound',
                  'Intravascular ultrasound'
                ]
              },
              'Virtual colonoscopy'
            ]
          },
          'Posturography'
        ],
        'Therapeutic' => [
          'Hemodialysis',
          'Extracorporeal membrane oxygenation (ECMO)',
          'Physical therapy/Physiotherapy',
          {
            'Shock therapy' => [
              'Insulin shock therapy',
              'Symptomatic treatment'
            ]
          },
          'Transcutaneous electrical nerve stimulation (TENS)',
          'Animal-Assisted Therapy'
        ],
        'Surgical' => [
          'Amputation',
          'Cardiopulmonary resuscitation (CPR)',
          'Image-guided surgery'
        ],
        'Anesthesia' => [
          'Dissociative anesthesia',
          'General anesthesia',
          {
            'Local anesthesia' => [
              'Topical anesthesia',
              'Epidural',
              'Spinal anesthesia'
            ]
          },
          'Regional anesthesia'
        ],
        'Other' => [
          'Interventional radiology',
          'Screening'
        ]
      }
    end
    # rubocop:enbale Style/WordArray

    it { is_expected.to match expected_output }
  end
end
