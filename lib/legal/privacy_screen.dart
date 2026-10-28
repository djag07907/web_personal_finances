import 'package:flutter/material.dart';
import 'package:web_personal_finances/legal/widget/legal_reader_scaffold.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(final BuildContext context) {
    return const LegalReaderScaffold(
      title: 'Privacy Policy & Zero-Knowledge Architecture',
      lastUpdated: 'October 28, 2026',
      badgeText: 'Zero-Knowledge Cryptographic Privacy',
      badgeIcon: Icons.lock_outline,
      children: <Widget>[
        LegalHighlightBox(
          icon: Icons.shield_rounded,
          title: 'Zero-Knowledge Client-Side Encryption Guarantee',
          description:
              'Pecunia is built on an architectural premise of strict client-side encryption (Envelope Encryption). Your sensitive financial records—incomes, expenses, debt accounts, loan terms, accounts receivable, and savings goals—are encrypted using authenticated AES-256-GCM in your browser before transmission to the cloud. Neither Pecunia staff, database administrators, nor Google Firebase possess the decryption keys.',
        ),

        // Section 1
        LegalSection(
          number: '1',
          title: 'Introduction & Core Privacy Principles',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'This Privacy Policy describes how Pecunia Personal Finances ("Pecunia", "we", "us", or "our") handles personal data and cryptographic material when you access or use our application. We operate under three core commitments:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Data Minimization',
                text:
                    'We only store the minimum structural metadata necessary to authenticate your account and sync encrypted records.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Client-Side Key Custody',
                text:
                    'Master cryptographic keys exist exclusively in your browser memory during an active authenticated session and are purged upon sign-out.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Zero Data Monetization',
                text:
                    'We do not sell, rent, monetize, or broker your personal information or financial records to data brokers, advertisers, or financial marketers.',
              ),
            ],
          ),
        ),

        // Section 2
        LegalSection(
          number: '2',
          title: 'Cryptographic Engine & Key Hierarchy',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'To safeguard financial records without compromising multi-device cloud synchronization or risking unrecoverable data loss, Pecunia utilizes an industry-standard Envelope Encryption hierarchy:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Data Encryption Key (DEK)',
                text:
                    'A cryptographically random 256-bit symmetric key generated locally via CSPRNG. The DEK encrypts and decrypts all sensitive financial transaction fields using AES-256-GCM with fresh 12-byte initialization vectors (IVs) per operation.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Password Key Encryption Key (KEK-P)',
                text:
                    'Derived from your master password using PBKDF2 with HMAC-SHA256 (100,000 rounds) and a unique per-user 16-byte cryptographic salt. KEK-P encrypts the DEK for seamless daily login across your devices.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Recovery Key Encryption Key (KEK-R)',
                text:
                    'Derived from a 12-word cryptographic recovery phrase (BIP-39 English wordlist). KEK-R encrypts the DEK as an emergency fallback envelope.',
              ),
              LegalBulletPoint(
                boldPrefix: 'AEAD Ciphertext',
                text:
                    'Ciphertext payloads utilize authenticated encryption with associated data (AES-GCM), guaranteeing both confidentiality and mathematical tamper-resistance against database alteration.',
              ),
            ],
          ),
        ),

        // Section 3
        LegalSection(
          number: '3',
          title: 'Data Classification & Cloud Storage Partitioning',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'Documents stored within Google Firestore are strictly partitioned between encrypted ciphertext and non-sensitive plaintext metadata:',
              ),
              LegalSubheading('A. Encrypted Fields (AES-256-GCM Ciphertext)'),
              LegalParagraph(
                'The following fields are encrypted client-side and appear as opaque cryptographic strings in our cloud database:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Incomes',
                text:
                    'Transaction amount, income source / employer title, user notes, and comments.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Expenses',
                text:
                    'Expense amount, merchant/vendor name, user notes, and payment method details.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Accounts to Pay',
                text:
                    'Creditor name, loan description, total liability balance, monthly quota, and the complete payments ledger (payment amounts, dates, and notes).',
              ),
              LegalBulletPoint(
                boldPrefix: 'Accounts Receivable',
                text:
                    'Debtor name, loan description, total receivable balance, monthly quota, and the complete payments ledger.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Savings Goals',
                text:
                    'Goal title, savings notes, initial amount, target goal amount, and the complete deposits/withdrawals ledger.',
              ),
              LegalSubheading(
                'B. Plaintext Metadata (Operational Necessities)',
              ),
              LegalParagraph(
                'The following non-sensitive attributes remain unencrypted in Firestore:',
              ),
              LegalBulletPoint(
                boldPrefix: 'User Identifier (UID)',
                text:
                    'A random Firebase Auth UID required by Firestore multi-tenant security rules (request.auth.uid == userId) to enforce strict user-to-user database isolation.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Account Email',
                text:
                    'Required for account authentication, password recovery verification, and emergency key file labeling.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Currency Code',
                text:
                    'Currency denomination (USD or HNL) to enable dual-currency formatting without decrypting foreign records.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Timestamps & Dates',
                text:
                    'Due dates, receive dates, and record creation dates to enable calendar views and amortization schedules.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Structural Enums & Flags',
                text:
                    'Boolean flags (status, isPaid, isReceived, isLoan, isGoalReached) and high-level category enums used for dashboard KPIs.',
              ),
            ],
          ),
        ),

        // Section 4
        LegalSection(
          number: '4',
          title: 'Purposes & Legal Bases for Processing (GDPR Article 6)',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'Under the European General Data Protection Regulation (GDPR) and similar global standards, we process your personal data under the following legal bases:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Contractual Necessity',
                text:
                    'Processing your account email, UID, and synchronizing encrypted documents is strictly required to deliver the Service as agreed in our Terms of Service.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Legitimate Interests',
                text:
                    'Detecting fraud, mitigating security attacks, ensuring multi-device consistency, and maintaining infrastructure availability.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Legal Obligation',
                text:
                    'Complying with applicable tax, financial record-keeping, or lawful governmental requests where mandated by law.',
              ),
            ],
          ),
        ),

        // Section 5
        LegalSection(
          number: '5',
          title: 'European Privacy Rights (GDPR & UK GDPR)',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'If you are located in the European Economic Area (EEA), United Kingdom, or Switzerland, you are entitled to exercise the following data protection rights:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Right of Access (Art. 15)',
                text:
                    'You have the right to request a copy of the personal metadata and ciphertext records we hold about your account.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Right to Rectification (Art. 16)',
                text:
                    'You may update or correct your profile details directly from the Profile screen at any time.',
              ),
              LegalBulletPoint(
                boldPrefix:
                    'Right to Erasure / "Right to be Forgotten" (Art. 17)',
                text:
                    'You have the right to permanently purge your account and all associated encrypted records from our cloud database.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Right to Data Portability (Art. 20)',
                text:
                    'You may export your transaction data and emergency backup keys at any time while authenticated.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Right to Lodge a Complaint',
                text:
                    'You have the right to lodge a complaint with your local Data Protection Authority (DPA) if you believe our data practices violate privacy regulations.',
              ),
            ],
          ),
        ),

        // Section 6
        LegalSection(
          number: '6',
          title: 'California Privacy Disclosures (CCPA / CPRA)',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'Under the California Consumer Privacy Act (CCPA) as amended by the California Privacy Rights Act (CPRA), California residents are entitled to specific disclosures:',
              ),
              LegalBulletPoint(
                boldPrefix: 'No Sale or Sharing of Personal Data',
                text:
                    'Pecunia does NOT "sell" personal information, nor do we "share" personal information for cross-context behavioral advertising.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Categories Collected',
                text:
                    'Identifiers (email address, Firebase UID), Financial Information (stored strictly as authenticated AES-256-GCM ciphertext), and Internet Activity (minimal operational logs for system health).',
              ),
              LegalBulletPoint(
                boldPrefix: 'Non-Discrimination',
                text:
                    'We will not deny you services, charge you different prices, or provide a different quality of service for exercising your CCPA rights.',
              ),
            ],
          ),
        ),

        // Section 7
        LegalSection(
          number: '7',
          title: 'Cookies, Local Storage & In-Memory Vault Security',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'Our web application is designed with extreme privacy hygiene regarding client storage:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Zero Third-Party Advertising Trackers',
                text:
                    'We do not load third-party ad pixels, marketing beacons, or social tracking cookies (e.g. Meta Pixel, Google AdSense).',
              ),
              LegalBulletPoint(
                boldPrefix: 'In-Memory Session Keys',
                text:
                    'Your decrypted Data Encryption Key (DEK) is held EXCLUSIVELY in transient browser memory (RAM) via our SessionVault singleton. Keys are NEVER written to localStorage, IndexedDB, or browser cookies.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Essential Authentication Tokens',
                text:
                    'Firebase Auth utilizes standard, secure, HTTP-only session tokens to maintain your login status across browser refreshes.',
              ),
            ],
          ),
        ),

        // Section 8
        LegalSection(
          number: '8',
          title: 'Third-Party Infrastructure & International Data Transfers',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'Pecunia hosts its database and authentication services on Google Cloud Platform / Firebase. Cloud servers are distributed globally in certified data centers.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Cryptographic Invisibility',
                text:
                    'Even though cloud hardware resides with Google, all sensitive database documents are stored as cryptographic ciphertext. Google Cloud cannot inspect or parse your financial records.',
              ),
              LegalBulletPoint(
                boldPrefix: 'International Safeguards',
                text:
                    'Cross-border transfers of encrypted data comply with European Commission Standard Contractual Clauses (SCCs) and GDPR Article 46 requirements.',
              ),
            ],
          ),
        ),

        // Section 9
        LegalSection(
          number: '9',
          title: 'Emergency Recovery Key Custody & Account Deletion',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'During onboarding, Pecunia generates a unique 12-word cryptographic phrase and prompts you to download your Emergency Recovery Key (pecunia_recovery_key_<email>.txt).',
              ),
              LegalBulletPoint(
                boldPrefix: 'User Custody',
                text:
                    'You are the sole custodian of this recovery file. Store it in a password manager, offline encrypted volume, or safe physical location.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Permanent Account Purge',
                text:
                    'If you choose to delete your account, your profile document and all encrypted sub-records (incomes, expenses, accounts to pay, accounts receivable, and savings) are immediately and permanently erased from Firestore.',
              ),
            ],
          ),
        ),

        // Section 10
        LegalSection(
          number: '10',
          title: 'Children\'s Privacy (COPPA Compliance)',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'Pecunia is strictly intended for individuals 18 years of age or older. We do not knowingly collect, solicit, or maintain personal information from children under 13 (or under 16 in the European Union) under the Children\'s Online Privacy Protection Act (COPPA). If we discover that an account was created by a minor under these age limits, the account and all associated cloud records will be deleted immediately.',
              ),
            ],
          ),
        ),

        // Section 11
        LegalSection(
          number: '11',
          title: 'Security Defense-in-Depth & Threat Model',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'Pecunia employs multiple layers of defense to protect your data:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Transport Security',
                text:
                    'All network communication occurs strictly over TLS 1.3 encrypted connections.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Application Security',
                text:
                    'Client-side AES-256-GCM authenticated encryption prevents cloud credential compromise or database eavesdropping.',
              ),
              LegalBulletPoint(
                boldPrefix: 'Granular Firestore Rules',
                text:
                    'Database security rules enforce document-level ownership checks (resource.data.userId == request.auth.uid) on every single read, write, update, and delete request.',
              ),
            ],
          ),
        ),

        // Section 12
        LegalSection(
          number: '12',
          title: 'Policy Updates & Version History',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'We may revise this Privacy Policy periodically to reflect enhancements in our cryptographic architecture, product features, or evolving regulatory standards. Material changes will be communicated via in-app banners or notification to your registered account email address prior to taking effect.',
              ),
            ],
          ),
        ),

        // Section 13
        LegalSection(
          number: '13',
          title: 'Contact Information & Data Protection Officer',
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LegalParagraph(
                'If you have questions, comments, or requests regarding this Privacy Policy or wish to exercise your data subject rights, please reach out to our team at:',
              ),
              LegalBulletPoint(
                boldPrefix: 'Privacy Inquiries',
                text: 'privacy@pecunia.app',
              ),
              LegalBulletPoint(
                boldPrefix: 'Security Team',
                text: 'security@pecunia.app',
              ),
              LegalBulletPoint(
                boldPrefix: 'Data Protection Officer',
                text: 'dpo@pecunia.app',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
