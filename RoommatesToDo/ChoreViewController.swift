

import UIKit

class ChoreViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var tasks = [Task]()
    
    var finished:Bool = false
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
        super.viewWillAppear(animated)
        self.fetchData(isFinished: finished)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func fetchData(isFinished:Bool) {
        CloudKitManager.fetchChoreTasks(isFinished: isFinished) { (result, error) in
            guard let result = result else {return}
            self.tasks = result
            self.tableView.reloadData()
        }
    }
    @IBAction func clickSegmentedControl(_ sender: UISegmentedControl) {
        if (sender.selectedSegmentIndex == 0){
            finished = false
            self.fetchData(isFinished: finished)
        }else{
            finished = true
            self.fetchData(isFinished: finished)
        }
    }
    
}

extension ChoreViewController : UITableViewDelegate,UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.tasks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DashBoardTableViewCell") as! DashBoardTableViewCell
        cell.task = self.tasks[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 108
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let task = tasks[indexPath.row]
        
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") {[weak self] (_, ip) in
            let alert = UIAlertController(title: NSLocalizedString("Caution", comment: "caution"), message: "Sure to delete?", preferredStyle: .alert)
            let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { (action) in
                CloudKitManager.removeRecord(task.identifier!, completion: { (_, _) in
                    self?.tasks.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                })
            })
            let defaultAction = UIAlertAction(title:"Cancel", style: .default, handler: nil)
            alert.addAction(defaultAction)
            alert.addAction(deleteAction)
            self?.present(alert, animated: true, completion: nil)
        }
        
        let finishAction = UITableViewRowAction(style: .normal, title: "Finish") { [weak self](_, ip) in
            if (task.`repeat` == .NoRepeat){
                CloudKitManager.updateRecord(task.identifier!, recordData: ["finish":true], completion: { (_, _) in
                    self?.tasks.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                })
            }else {
                let index = self?.tasks.index{$0 === task}
                let removeTask = self?.tasks.remove(at: index!)
                self?.tasks.append(removeTask!)
                self?.tableView.reloadData()
                
            }
            
        }
        return [deleteAction, finishAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = tasks[indexPath.row]
        let viewController = self.storyboard?.instantiateViewController(withIdentifier: "ChoreDetailViewController") as! ChoreDetailViewController
        viewController.task = task
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}

