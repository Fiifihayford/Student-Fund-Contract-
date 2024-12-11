// SPDX-License-Identifier: MIT
pragma solidity ^0.8;
import{priceconvertor} from "./priceconverter.sol";
using priceconvertor  for uint256;
contract StudentFund{ 

    uint256 constant MinimumAmountinUSD = 1e18;// Minimum amount to be donated
    address immutable  I_SchoolAddress;
    
    struct StudentDetails{ // Parameters for student eligible to be funded
    string name;
    address StudentAdress;
    bool schoolfees;
    }

    event _studentAdded(string, address indexed,bool);//events for student records
    event _Fundcontract(bool,address,uint256);// Event for funders
    event _withdrawal(address indexed , uint256); 

    mapping(address funders => uint256 AmountDonated) public Funders; // container for mapping amount donated by founder. 
    address [] public FundersAddress;// address of funders;

    mapping(address => StudentDetails) public students;// mapping to store student details by their addresses
    StudentDetails[] public StudentDetailsData;

    constructor (){
        I_SchoolAddress = msg.sender;
    }

     modifier OnlyOwner(){
        require(I_SchoolAddress == msg.sender, "Only the owner can redraw");
        _;
     }

     modifier FeesStatus( address _studentAddress){
        require(!students[_studentAddress].schoolfees,"Student's schoolfees has been paid already");  
        _; 
    }  

   function InputStudentRecords(string memory _name, address _studentAddress, bool _fees) public OnlyOwner {// input student details into StudentDetails array storage 
          require(_studentAddress != address(0), "Invalid student Address");
          students[_studentAddress] = StudentDetails({name: _name, StudentAdress: _studentAddress, schoolfees: _fees});
          emit _studentAdded(_name,_studentAddress,_fees);
   }

    function FundStudent(address _studentFees ) public payable FeesStatus( _studentFees){
        require(msg.value.GetConversionRate() >= MinimumAmountinUSD, "value is less than a dollar");
        FundersAddress.push(msg.sender);  
        Funders[msg.sender]+= msg.value;     
    }

    function withdraw() public OnlyOwner{
        for(uint256 index = 0; index<FundersAddress.length; index++){
          address arraddresses = FundersAddress[index];
          Funders[arraddresses]=0;
        }

        FundersAddress = new address[](0);
        (bool callSuccess,) = payable(msg.sender).call{value:address(this).balance}("");
        require(callSuccess = true,  "CallFailed");

        emit  _withdrawal(msg.sender,address(this).balance);
    }
           
    receive() external payable { 
       revert("Unexpected Ether transfer. Please use the FundStudent function.");
    }

    fallback() external payable { 
        revert("Unexpected Ether transfer. Please use the FundStudent function.");
    }
} 