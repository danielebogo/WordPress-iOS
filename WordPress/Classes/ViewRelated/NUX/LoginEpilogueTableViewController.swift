import UIKit
import WordPressShared


// MARK: - LoginEpilogueTableViewController
//
class LoginEpilogueTableViewController: UITableViewController {

    ///
    ///
    private let blogDataSource = BlogListDataSource()

    ///
    ///
    private var epilogueUserInfo: LoginEpilogueUserInfo?

    /// Site that was just connected to our awesome app.
    ///
    private var endpoint: WordPressEndpoint?


    // MARK: - Initializers

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let headerNib = UINib(nibName: "EpilogueSectionHeaderFooter", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: Settings.headerReuseIdentifier)

        let userInfoNib = UINib(nibName: "EpilogueUserInfoCell", bundle: nil)
        tableView.register(userInfoNib, forCellReuseIdentifier: Settings.userCellReuseIdentifier)
    }

    ///
    ///
    func setup(with endpoint: WordPressEndpoint) {
        self.endpoint = endpoint
        refreshInterface(for: endpoint)
    }
}


// MARK: - UITableViewDataSource methods
//
extension LoginEpilogueTableViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return blogDataSource.numberOfSections(in: tableView) + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }

        let correctedSection = section - 1
        return blogDataSource.tableView(tableView, numberOfRowsInSection: correctedSection)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: Settings.userCellReuseIdentifier) as? EpilogueUserInfoCell else {
                fatalError("Failed to get a user info cell")
            }

            if let info = epilogueUserInfo {
                cell.configure(userInfo: info)
            }

            return cell
        }

        let wrappedPath = IndexPath(row: indexPath.row, section: indexPath.section-1)
        return blogDataSource.tableView(tableView, cellForRowAt: wrappedPath)
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let cell = tableView.dequeueReusableHeaderFooterView(withIdentifier: Settings.headerReuseIdentifier) as? EpilogueSectionHeaderFooter else {
            fatalError("Failed to get a section header cell")
        }

        cell.titleLabel?.text = title(for: section)

        return cell
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 {
            return Settings.profileRowHeight
        }

        return Settings.blogRowHeight
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForHeaderInSection section: Int) -> CGFloat {
        return Settings.headerHeight
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return UITableViewAutomaticDimension
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
}


// MARK: - UITableViewDelegate methods
//
extension LoginEpilogueTableViewController {

    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        guard let headerView = view as? UITableViewHeaderFooterView else {
            return
        }

        headerView.textLabel?.font = UIFont.preferredFont(forTextStyle: .footnote)
        headerView.textLabel?.textColor = WPStyleGuide.greyDarken20()
        headerView.contentView.backgroundColor = WPStyleGuide.lightGrey()
    }
}


// MARK: - Private Methods
//
private extension LoginEpilogueTableViewController {

    /// Returns the title for the current section!.
    ///
    func title(for section: Int) -> String {
        if section == 0 {
            return NSLocalizedString("Logged In As", comment: "Header for user info, shown after loggin in").localizedUppercase
        }

        let rowCount = blogDataSource.tableView(tableView, numberOfRowsInSection: section-1)
        if rowCount > 1 {
            return NSLocalizedString("My Sites", comment: "Header for list of multiple sites, shown after loggin in").localizedUppercase
        }

        return NSLocalizedString("My Site", comment: "Header for a single site, shown after loggin in").localizedUppercase
    }
}


// MARK: - Loading!
//
private extension LoginEpilogueTableViewController {

    ///
    ///
    func refreshInterface(for endpoint: WordPressEndpoint) {
        switch endpoint {
        case .wpcom:
            epilogueUserInfo = loadEpilogueForDotcom()
            blogDataSource.loggedIn = true

            tableView.reloadData()

        case .wporg(let username, let password, let xmlrpc, _):
            blogDataSource.blog = loadBlog(username: username, xmlrpc: xmlrpc)

            loadEpilogueForSelfhosted(username: username, password: password, xmlrpc: xmlrpc) { [weak self] epilogueInfo in
                self?.epilogueUserInfo = epilogueInfo
                self?.tableView.reloadData()
            }
        }
    }

    /// Loads the Blog for a given Username / XMLRPC, if any.
    ///
    private func loadBlog(username: String, xmlrpc: String) -> Blog? {
        let context = ContextManager.sharedInstance().mainContext
        let service = BlogService(managedObjectContext: context)

        return service.findBlog(withXmlrpc: xmlrpc, andUsername: username)
    }

    /// The self-hosted flow sets user info, if no user info is set, assume a wpcom flow and try the default wp account.
    ///
    private func loadEpilogueForDotcom() -> LoginEpilogueUserInfo {
        let context = ContextManager.sharedInstance().mainContext
        let service = AccountService(managedObjectContext: context)
        guard let account = service.defaultWordPressComAccount() else {
            fatalError()
        }

        return LoginEpilogueUserInfo(account: account)
    }

    /// Loads the EpilogueInfo for a SelfHosted site, with the specified credentials, at the given endpoint.
    ///
    private func loadEpilogueForSelfhosted(username: String, password: String, xmlrpc: String, completion: @escaping (LoginEpilogueUserInfo?) -> ()) {
        guard let service = UsersService(username: username, password: password, xmlrpc: xmlrpc) else {
            completion(nil)
            return
        }

        /// Load: User's Profile
        ///
        service.fetchProfile { userProfile in
            guard let userProfile = userProfile else {
                completion(nil)
                return
            }

            var epilogueInfo = LoginEpilogueUserInfo()
            epilogueInfo.update(with: userProfile)

            /// Load: Gravatar's Metadata
            ///
            let service = GravatarService()
            service.fetchProfile(email: userProfile.email) { gravatarProfile in
                if let gravatarProfile = gravatarProfile {
                    epilogueInfo.update(with: gravatarProfile)
                }

                completion(epilogueInfo)
            }
        }
    }
}


// MARK: - UITableViewDelegate methods
//
private extension LoginEpilogueTableViewController {

    struct Settings {
        static let headerReuseIdentifier = "SectionHeader"
        static let userCellReuseIdentifier = "UserCell"
        static let profileRowHeight = CGFloat(140)
        static let blogRowHeight = CGFloat(52)
        static let headerHeight = CGFloat(50)
    }
}
