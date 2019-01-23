    //
    //  HomeView.swift
    //  Prototype_IOS
    //
    //  Created by Vincent Dandenault on 2018-10-04.
    //  Copyright © 2018 Vincent Dandenault. All rights reserved.
    //
    
    import UIKit
    import Alamofire
    import AVFoundation
    
    //NOTE : SOCKETS FOR WORKSACES AVAIBLE IN PROGRESS2
    
    class HomeViewPPP: UIViewController {
        
        var workspaces: [Workspace] = []
        var tempWorkspace = Workspace.init()
        let blackView = UIView()

        override func viewDidLoad() {
            super.viewDidLoad()
            workspaceTableView.delegate = self
            workspaceTableView.dataSource = self
            Socket.shared.socketWorkspacesDelegate = self
            self.newWorkspaceView.isHidden = true
            self.passwordView.isHidden = true
            Socket.shared.getWorkspaces()
        }
        
        override func didReceiveMemoryWarning() {
            super.didReceiveMemoryWarning()
            // Dispose of any resources that can be recreated.
        }
        //MARK: - UI variables
        @IBOutlet weak var workspaceNameTextField: UITextField!
        @IBOutlet weak var passwordTextField: UITextField!
        @IBOutlet weak var workspaceTableView: UITableView!
        @IBOutlet weak var passwordView: UIView!
        @IBOutlet weak var newWorkspaceView: UIView!
        
        
        @IBAction func enterButtonTapped(_ sender: Any) {
            self.performSegue(withIdentifier: "toPolyPaintPro", sender: self)
        }
        
        @IBAction func plusButtonTapped(_ sender: Any) {
            if let window = UIApplication.shared.keyWindow {
                self.blackView.backgroundColor = UIColor(white: 0, alpha: 0.5)
                window.addSubview(blackView)
                self.blackView.frame = window.frame
                self.blackView.alpha = 0
                UIView.animate(withDuration: 0.5, animations: {
                    self.blackView.alpha = 1
                    window.addSubview(self.newWorkspaceView)
                    self.newWorkspaceView.isHidden = false
                })
            }
        }
        @IBAction func goTapped(_ sender: Any) {
            if (!(self.workspaceNameTextField.text?.isEmpty)!) {
                let workspaceName = self.workspaceNameTextField.text!
                let newWorkspace = Workspace(name: workspaceName, sessionId: "", author: User.shared.name)
                newWorkspace.joinWorkspace()
                UIView.animate(withDuration: 0.5) {
                    self.newWorkspaceView.isHidden = true
                    self.blackView.alpha = 0
                }
                self.performSegue(withIdentifier: "toPolyPaintPro", sender: self)
            }
            else {
                Alert.showBasic(title: "Empty Name", message: "Please enter a name", vc: self)
            }
        }
        @IBAction func exitTapped(_ sender: Any) {
            UIView.animate(withDuration: 0.5) {
                self.newWorkspaceView.isHidden = true
                self.blackView.alpha = 0
            }
        }
        
        @IBAction func homeTapped(_ sender: Any) {
            performSegue(withIdentifier: "toHomeFromHomePPP", sender: self)
        }
        @IBAction func passwordEnterTapped(_ sender: Any) {
        }
        
        // MARK: - Navigation
        override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier ==  "toPolyPaintPro" {
                if let polyPaintProVC = segue.destination as? PolyPaintPro {
                    polyPaintProVC.workspace = self.tempWorkspace
                }
            }
            if (segue.identifier == "toHomeFromHomePPP") {
                Socket.shared.leaveWorkSpace()
            }
        }
    }
    
    
    
    
    // MARK: - WorkspaceTableView
    extension HomeViewPPP: UITableViewDelegate, UITableViewDataSource {
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return workspaces.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let workspace = workspaces[indexPath.row]
            let cell = workspaceTableView.dequeueReusableCell(withIdentifier: "workspaceCell") as! WorkspaceCell
            cell.setWorkspaceCell(workspace: workspace)
            return cell
        }
        func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
            if (editingStyle == .delete) {
                workspaces.remove(at: indexPath.row)
                workspaceTableView.beginUpdates()
                workspaceTableView.deleteRows(at: [indexPath], with: .automatic)
                workspaceTableView.endUpdates()
            }
        }
        func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            let workspace = workspaces[indexPath.row]
            //let cell =  workspaceTableView.dequeueReusableCell(withIdentifier: "workspaceCell", for: indexPath) as! WorkspaceCell
            workspace.joinWorkspace()
            tempWorkspace = workspace
            self.performSegue(withIdentifier: "toPolyPaintPro", sender: self)
        }
    }
    
    extension HomeViewPPP: SocketWorkspacesDelegate {
        func getWorkspaces(workspaces: [String]) {
            var Workspaces: [Workspace] = []
            for string in workspaces {
                let workspace = Workspace(name: "NoName", sessionId: string, author: "")
                Workspaces.append(workspace)
            }
            self.workspaces = Workspaces
            self.workspaceTableView.reloadData()
        }
}
    

   

