// const userTransaction = JSON.parse(localStorage.getItem("transactions"));
// const User = JSON.parse(localStorage.getItem("User"));
// console.log("transaction", userTransaction);
// console.log("user", User);
// function generateCountDown() {
//   var now = new Date().getDate();
//   var minutes = Math.floor((now % (1000 * 60 * 60)) / (1000 * 60));
//   var seconds = Math.floor((now % (1000 * 60)) / 1000);
//   return minutes + "m" + seconds + "s";
// }
// const contractTransactionList = document.querySelector(".dataUserTransaction");
// const UserProfile = document.querySelector(".contract-user");
// //card
// const userTransactionHistory = userTransaction.map((transaction, i) => {
//   return `<div
//                 class="col-12 col-md-6 col-lg-4 item explore-item"
//                 data-groups='["ongoing", "ended"]'
//               >
//                 <div class="card project-card">
//                   <div class="media">
//                     <a href="project-details.html">
//                       <img
//                         src="assets/img/content/thumb_${i + 1}.png"
//                         alt=""
//                         class="card-img-top avatar-max-lg"
//                       />
//                     </a>
//                     <div class="media-body ml-4">
//                       <a href="project-details.html">
//                         <h4 class="m-0">#tbCoders</h4>
//                       </a>
//                       <div class="countdown-times">
//                         <h6 class="my-2">Transaction NO: ${i + 1}</h6>
//                         <div
//                           class="countdown d-flex"
//                           data-data="2022-06-30"
//                         ></div>
//                       </div>
//                     </div>
//                   </div>
//                   <div class="card-body">
//                     <div class="items">
//                       <div class="single-item">
//                         <span>${
//                           transaction.token / 10 ** 18
//                             ? "Amount"
//                             : "Claim Token"
//                         }</span>
//                         <span>${transaction.token / 10 ** 18 || ""}</span>
//                       </div>
//                       <div class="single-item">
//                         <span>Gas</span>
//                         <span>${transaction.gasUsed}</span>
//                       </div>
//                       <div class="single-item">
//                         <span>Status</span>
//                         <span>${transaction.status}</span>
//                       </div>
//                     </div>
//                   </div>
//                   <div
//                     class="project-footer d-flex align-items-center mt-4 mt-md-5"
//                   >
//                     <a
//                       class="btn btn-bordered-white btn-smaller"
//                       href="https://sepolia.etherscan.io/tx/${
//                         transaction.transactionHash
//                       }"
//                     >
//                       Transaction
//                     </a>
//                   </div>
//                 </div>
//               </div>`;
// });
// //user
// const userProfileHTML = `
//   <div class="contract-user-profile">
//     <img src="assets/img/content/team_1.png" alt="" />
//     <div class="contract-user-profile-info">
//       <p><strong>Address:</strong> ${User.address.slice(0, 25)}..</p>
//       <span class="contract-space"><strong>Stake Amount:&nbsp;</strong>${
//         User.stakeAmount / 10 ** 18
//       }</span>
//       <span class="contract-space"><strong>last Reward Calculation Time:&nbsp;</strong>${generateCountDown(
//         User.lastRewardCalculationTime
//       )}</span>
//       <span class="contract-space"><strong>last stake Time:&nbsp;</strong>${generateCountDown(
//         User.lastStakeTime
//       )}</span>
//       <span class="contract-space"><strong>Reward Token:</strong>${
//         User.rewardAmount / 10 ** 18
//       }</span>
//       <span class="contract-space"><strong>Rewards Claimed So Far:&nbsp</strong>${
//         User.rewardsClaimedSoFar / 10 ** 18
//       }</span>
//     </div>
//   </div>
// `;

// UserProfile.innerHTML = userProfileHTML;
// contractTransactionList.innerHTML = userTransactionHistory;
// Retrieve the transactions and user data from localStorage
const userTransaction = JSON.parse(localStorage.getItem("transactions"));
const User = JSON.parse(localStorage.getItem("User"));

console.log("transaction", userTransaction);
console.log("user", User);

// Function to generate a countdown (though it seems to just return minutes and seconds based on the current date)
function generateCountDown(timestamp) {
  const now = new Date();
  const targetTime = new Date(parseInt(timestamp) * 1000); // Assuming the timestamp is in seconds
  const timeDiff = targetTime - now;

  if (timeDiff > 0) {
    const minutes = Math.floor((timeDiff % (1000 * 60 * 60)) / (1000 * 60));
    const seconds = Math.floor((timeDiff % (1000 * 60)) / 1000);
    return `${minutes}m ${seconds}s`;
  } else {
    return `0m 0s`; // Time has passed
  }
}

// Select the HTML elements where the data will be injected
const contractTransactionList = document.querySelector(".dataUserTransaction");
const UserProfile = document.querySelector(".contract-user");

// Check if user data is available and render it
if (User && UserProfile) {
  const userProfileHTML = `
    <div class="contract-user-profile">
      <img src="assets/img/content/team_1.png" alt="User Image" style="width: 100px; border-radius: 50%;" />
      <div class="contract-user-profile-info" style="color: white;">
        <p><strong>Address:</strong> ${User.address.slice(0, 25)}...</p>
        <p><strong>Stake Amount:</strong> ${User.stakeAmount / 10 ** 18}</p>
        <p><strong>Last Reward Calculation Time:</strong> ${generateCountDown(
          User.lastRewardCalculationTime
        )}</p>
        <p><strong>Last Stake Time:</strong> ${generateCountDown(
          User.lastStakeTime
        )}</p>
        <p><strong>Reward Token:</strong> ${User.rewardAmount / 10 ** 18}</p>
        <p><strong>Rewards Claimed So Far:</strong> ${
          User.rewardsClaimedSoFar / 10 ** 18
        }</p>
      </div>
    </div>
  `;
  UserProfile.innerHTML = userProfileHTML;
} else {
  console.error("User data is missing or UserProfile element not found.");
}

// Check if transaction data is available and render it
if (userTransaction && contractTransactionList) {
  const userTransactionHistory = userTransaction
    .map((transaction, i) => {
      return `
      <div class="col-12 col-md-6 col-lg-4 item explore-item" data-groups='["ongoing", "ended"]'>
        <div class="card project-card">
          <div class="media">
            <a href="project-details.html">
              <img src="assets/img/content/thumb_${
                i + 1
              }.png" alt="Transaction Image" class="card-img-top avatar-max-lg" />
            </a>
            <div class="media-body ml-4">
              <a href="project-details.html">
                <h4 class="m-0">#tbCoders</h4>
              </a>
              <div class="countdown-times">
                <h6 class="my-2">Transaction NO: ${i + 1}</h6>
                <div class="countdown d-flex" data-data="2022-06-30"></div>
              </div>
            </div>
          </div>
          <div class="card-body">
            <div class="items">
              <div class="single-item">
                <span>${
                  transaction.token / 10 ** 18 ? "Amount" : "Claim Token"
                }</span>
                <span>${transaction.token / 10 ** 18 || ""}</span>
              </div>
              <div class="single-item">
                <span>Gas</span>
                <span>${transaction.gasUsed}</span>
              </div>
              <div class="single-item">
                <span>Status</span>
                <span>${transaction.status}</span>
              </div>
            </div>
          </div>
          <div class="project-footer d-flex align-items-center mt-4 mt-md-5">
            <a class="btn btn-bordered-white btn-smaller" href="https://sepolia.etherscan.io/tx/${
              transaction.transactionHash
            }">
              View Transaction
            </a>
          </div>
        </div>
      </div>`;
    })
    .join(""); // Join the array of HTML strings into one string

  contractTransactionList.innerHTML = userTransactionHistory;
} else {
  console.error(
    "Transaction data is missing or contractTransactionList element not found."
  );
}
