import 'package:flutter/material.dart';
import 'package:web_personal_finances/legal/widget/legal_reader_scaffold.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return const LegalReaderScaffold(
      title: 'Terms of Service',
      lastUpdated: 'October 28, 2026',
      badgeText: 'Legal Agreement & Terms of Service',
      badgeIcon: Icons.description_outlined,
      children: <Widget>[
        LegalHighlightBox(
          icon: Icons.gavel_rounded,
          title: 'Binding Legal Agreement',
          description:
              'Please read these Terms of Service carefully before creating an account or using Pecunia. They define your legal rights, our Zero-Knowledge security responsibilities, limitations of liability, and mandatory individual arbitration for dispute resolution.',
        ),

        // Section 1
        LegalSection(
          number: '1',
          title: 'Acceptance of Terms & Eligibility',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'By registering for, accessing, or using the Pecunia Personal Finances application (including our web platform, mobile interfaces, and associated cloud synchronization services, collectively referred to as the "Service"), you agree to be bound by these Terms of Service ("Terms") and our Privacy Policy.',
              ),
              LegalParagraph(
                'To use the Service, you represent and warrant that:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Legal Age',
                text:
                    'You are at least 18 years of age (or the age of legal majority in your country or state of residence).',
              ),
              LegalBulletPoint(
                boldPrefix: 'Capacity',
                text:
                    'You have the legal authority and capacity to enter into a legally binding contract with Pecunia.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Compliance',
                text:
                    'Your use of the Service complies with all local, state, national, and international laws, regulations, and statutes.',
              ),
              LegalParagraph(
                'If you do not agree to all terms and conditions set forth herein, you must immediately discontinue use of the Service and refrain from creating an account.',
              ),
            ],
          ),
        ),

        // Section 2
        LegalSection(
          number: '2',
          title: 'Zero-Knowledge Security Model & Cryptographic Custody',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'Pecunia is built upon an architectural foundation of Zero-Knowledge Client-Side Encryption (Envelope Encryption). By using our Service, you explicitly understand and acknowledge the following cryptographic realities:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Sole Custody',
                text:
                    'Your Data Encryption Key (DEK) is generated locally in your browser memory and is encrypted by your Master Password (KEK-P) and your 12-Word BIP-39 Recovery Key (KEK-R). Pecunia servers and staff do not possess your keys.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Permanent Unrecoverability',
                text:
                    'If you forget your master account password AND permanently lose your downloaded Emergency Recovery Key file (pecunia_recovery_key_<email>.txt), Pecunia employees, automated systems, and database administrators CANNOT decrypt, recover, or restore your encrypted financial records. Data loss under these circumstances is irreversible.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Mandatory Backup',
                text:
                    'You are solely responsible for downloading, safeguarding, and backing up your 12-word Emergency Recovery Key in an offline, password-manager, or physical storage environment.',
              ),
            ],
          ),
        ),

        // Section 3
        LegalSection(
          number: '3',
          title: 'Account Registration & Credential Security',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'When registering an account, you must provide accurate and verifiable account details (such as a valid email address). You are solely responsible for all activities that occur under your account credentials.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Confidentiality',
                text:
                    'You agree to maintain the strict confidentiality of your master password and downloaded emergency keys, and not disclose them to any third party.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Notification',
                text:
                    'You agree to notify Pecunia security immediately if you suspect unauthorized access or any security breach affecting your account.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Account Non-Transferability',
                text:
                    'Your Pecunia account is strictly personal. You may not sell, lease, transfer, or assign your account to any other individual or entity.',
              ),
            ],
          ),
        ),

        // Section 4
        LegalSection(
          number: '4',
          title: 'Authorized License & Acceptable Use Restrictions',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'Pecunia grants you a personal, revocable, non-exclusive, non-transferable, and limited license to access and use the Service strictly for your individual and household financial budgeting and tracking.',
              ),
              LegalParagraph(
                'You agree that you will NOT, and will not permit any third party to:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Security Probing',
                text:
                    'Circumvent, reverse engineer, decompile, disable, or tamper with any cryptographic protections, encryption boundaries, firestore security rules, or tenant isolation systems.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Automated Abuse',
                text:
                    'Employ automated bots, spiders, scrapers, or scripts to flood, extract data, or generate excessive load on our infrastructure.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Illegal Activities',
                text:
                    'Use the Service to facilitate, conceal, or record funds derived from money laundering, terrorist financing, fraud, or other unlawful activities.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Unauthorized Distribution',
                text:
                    'Sublicense, resell, rent, timeshare, or commercially redistribute access to the software without express prior written consent from Pecunia.',
              ),
            ],
          ),
        ),

        // Section 5
        LegalSection(
          number: '5',
          title: 'Financial Information & Non-Advisory Disclaimer',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalHighlightBox(
                icon: Icons.warning_amber_rounded,
                title: 'No Professional Financial, Tax, or Legal Advice',
                description:
                    'Pecunia is a software tracking and organizational utility only. It does not provide certified financial planning, tax accounting, legal counsel, or investment advisory services.',
              ),
              LegalParagraph(
                'All charts, KPIs, debt amortization schedules, loan projections, interest calculations, and net savings balances provided within the Service are generated algorithmically for informational self-tracking only.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Calculation Approximations',
                text:
                    'Calculations (including French, German, or Flat amortization schedules) may differ slightly from your lender\'s internal proprietary accounting, compound day counts, or banking penalties.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Independent Consultation',
                text:
                    'You should always review formal loan documents and consult a licensed certified public accountant (CPA), financial planner, or attorney before making major financial decisions.',
              ),
            ],
          ),
        ),

        // Section 6
        LegalSection(
          number: '6',
          title: 'Intellectual Property & Ownership of Financial Data',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'We respect your property rights. Our agreement regarding intellectual property is divided as follows:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Your Data',
                text:
                    'You retain 100% full, exclusive ownership of all financial transactions, comments, amounts, and personal metadata inputted into your account. Pecunia claims no intellectual property rights or ownership interest in your financial data.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Pecunia Software',
                text:
                    'Pecunia, its logos, trademarks, source code, user interface designs, algorithmic workflows, visual elements, and documentation remain the exclusive intellectual property of Pecunia and its licensors, protected by copyright, trademark, and international treaties.',
              ),
            ],
          ),
        ),

        // Section 7
        LegalSection(
          number: '7',
          title: 'Cloud Infrastructure, Synchronization & Service Availability',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'The Service relies on third-party cloud infrastructure (specifically Google Cloud Platform / Firebase) for authentication, ciphertext storage, and multi-device synchronisation.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Target Availability',
                text:
                    'While we endeavor to provide continuous availability (targeting 99.9% uptime), we do not warrant that the Service will be completely uninterrupted, timely, or error-free.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Maintenance',
                text:
                    'We reserve the right to perform scheduled or emergency maintenance, system patches, and database upgrades that may temporarily interrupt access.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Offline Limitations',
                text:
                    'Client-side actions taken while offline will synchronize upon establishing an active internet connection, subject to browser memory cache limits.',
              ),
            ],
          ),
        ),

        // Section 8
        LegalSection(
          number: '8',
          title: 'Subscriptions, Fees & Future Billing Terms',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'Currently, standard access to Pecunia is provided free of charge. In the event Pecunia introduces paid subscription tiers, enhanced premium analytics, or advanced institutional features:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Advance Notice',
                text:
                    'Existing users will be given at least 30 days prior written notice via their registered account email before any fees apply to their existing workflow.',
              ),
              LegalBulletPoint(
                boldPrefix: 'No Automatic Involuntary Billing',
                text:
                    'You will never be charged without explicitly opting into a paid tier and submitting payment information.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Taxes',
                text:
                    'Users are responsible for any applicable regional sales, consumption, or value-added taxes (VAT) associated with future paid services.',
              ),
            ],
          ),
        ),

        // Section 9
        LegalSection(
          number: '9',
          title: 'Disclaimer of Warranties ("AS IS")',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'TO THE MAXIMUM EXTENT PERMITTED UNDER APPLICABLE LAW, THE SERVICE, DOCUMENTATION, AND ALL CONTENT ARE PROVIDED ON AN "AS IS" AND "AS AVAILABLE" BASIS, WITH ALL FAULTS AND WITHOUT WARRANTY OF ANY KIND.',
              ),
              LegalParagraph(
                'PECUNIA EXPRESSLY DISCLAIMS ALL WARRANTIES, WHETHER STATUTORY, EXPRESS, IMPLIED, OR OTHERWISE, INCLUDING WITHOUT LIMITATION THE IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, TITLE, ACCURACY, AND NON-INFRINGEMENT.',
              ),
              LegalParagraph(
                'PECUNIA MAKES NO WARRANTY THAT (A) THE SERVICE WILL MEET YOUR SPECIFIC REQUIREMENTS, (B) DATA TRANSMISSIONS WILL BE UNINTERRUPTED OR ERROR-FREE, OR (C) ENCRYPTED BACKUPS WILL PREVENT LOCAL HARDWARE DESTRUCTION OR USER KEY LOSS.',
              ),
            ],
          ),
        ),

        // Section 10
        LegalSection(
          number: '10',
          title: 'Limitation of Liability',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL PECUNIA, ITS AFFILIATES, OFFICERS, EMPLOYEES, DIRECTORS, OR CLOUD PROVIDERS BE LIABLE FOR ANY INDIRECT, INCIDENTAL, CONSEQUENTIAL, SPECIAL, PUNITIVE, OR EXEMPLARY DAMAGES (INCLUDING DAMAGES FOR LOSS OF PROFITS, REVENUE, GOODWILL, RECOVERY KEY LOSS, UNRECOVERABLE DATA CORRUPTION, OR INACCURATE FINANCIAL PROJECTIONS).',
              ),
              LegalParagraph(
                'PECUNIA\'S TOTAL AGGREGATE LIABILITY ARISING OUT OF OR RELATING TO THESE TERMS OR YOUR USE OF THE SERVICE SHALL BE STRICTLY LIMITED TO THE GREATER OF: (A) THE TOTAL AMOUNT ACTUALLY PAID BY YOU TO PECUNIA IN THE TWELVE (12) MONTHS PRECEDING THE CLAIM, OR (B) ONE HUNDRED UNITED STATES DOLLARS (\$100.00 USD).',
              ),
            ],
          ),
        ),

        // Section 11
        LegalSection(
          number: '11',
          title: 'Indemnification',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'You agree to defend, indemnify, and hold harmless Pecunia, its affiliates, licensors, contractors, and employees from and against any claims, liabilities, damages, losses, costs, or expenses (including reasonable attorney fees) arising from or relating to: (a) your breach of these Terms, (b) your violation of any third-party rights, or (c) any unlawful conduct, fraud, or willful misconduct associated with your account.',
              ),
            ],
          ),
        ),

        // Section 12
        LegalSection(
          number: '12',
          title: 'Dispute Resolution, Binding Arbitration & Class Action Waiver',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'PLEASE READ THIS SECTION CAREFULLY. IT CONTAINS A MANDATORY ARBITRATION CLAUSE AND A WAIVER OF CLASS ACTION LAWSUITS AFFECTING YOUR LEGAL RIGHTS.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Informal Resolution',
                text:
                    'Before initiating any formal legal proceeding, you and Pecunia agree to attempt to resolve any dispute informally by contacting our legal team at legal@pecunia.app for a period of at least 30 days.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Binding Individual Arbitration',
                text:
                    'If informal resolution fails, any unresolved claim or controversy shall be determined by final and binding individual arbitration administered by an established arbitration provider under its commercial arbitration rules.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Class Action Waiver',
                text:
                    'YOU AND PECUNIA AGREE THAT EACH PARTY MAY BRING CLAIMS AGAINST THE OTHER ONLY IN AN INDIVIDUAL CAPACITY, AND NOT AS A PLAINTIFF OR CLASS MEMBER IN ANY PURPORTED CLASS, CONSOLIDATED, OR REPRESENTATIVE PROCEEDING.',
              ),
            ],
          ),
        ),

        // Section 13
        LegalSection(
          number: '13',
          title: 'Governing Law & Jurisdiction',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'These Terms and any dispute arising out of or related to your use of Pecunia shall be governed by and construed in accordance with the substantive laws of Delaware, United States (without regard to its conflict of law principles).',
              ),
              LegalParagraph(
                'To the extent that court litigation is permitted under Section 12, both parties agree to submit to the exclusive personal jurisdiction of the state and federal courts located within Wilmington, Delaware.',
              ),
            ],
          ),
        ),

        // Section 14
        LegalSection(
          number: '14',
          title: 'Termination & Account Erasure',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'You may terminate this agreement at any time by deleting your account via the settings in your Profile screen or by contacting our team. Upon termination:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Complete Erasure',
                text:
                    'All your cloud profile documents and encrypted records across all collections are permanently purged from Firestore.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Survival',
                text:
                    'Provisions regarding Intellectual Property, Disclaimer of Warranties, Limitation of Liability, Indemnification, and Dispute Resolution shall survive account termination.',
              ),
            ],
          ),
        ),

        // Section 15
        LegalSection(
          number: '15',
          title: 'General Provisions & Contact Information',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalBulletPoint(
                boldPrefix: 'Severability',
                text:
                    'If any provision of these Terms is found to be unlawful or unenforceable, that provision will be severed without affecting the validity of the remaining provisions.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Entire Agreement',
                text:
                    'These Terms and our Privacy Policy constitute the entire agreement between you and Pecunia concerning the Service, superseding all prior oral or written agreements.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Contact',
                text:
                    'For questions, inquiries, or legal notices regarding these Terms, please contact us at: legal@pecunia.app.',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
