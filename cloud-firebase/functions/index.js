const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();


exports.sendOrderTakenNotification = functions.database.ref('/order/{userUid}/taken/{orderId}')
    .onWrite(async (change, context) => {
      const userUid = context.params.userUid;
      const orderId = context.params.orderId;

      console.log('New order taken ID:', orderId, 'from user:', userUid);

      // Get the list of device notification tokens.
      const getDeviceTokensPromise = admin.database()
          .ref(`/users/${userUid}/notificationToken`).once('value');

      // podria estar bueno tener el id del usuario que tomo el pedido
      //const getFollowerProfilePromise = admin.auth().getUser(userCapoId);

      // The snapshot to the user's tokens.
      let tokensSnapshot;

      // The array containing all the user's tokens.
      let tokens;

      const results = await Promise.all([getDeviceTokensPromise]);//, getFollowerProfilePromise]);
      tokensSnapshot = results[0];
      //const follower = results[1];

      // Check if there are any device tokens.
      if (!tokensSnapshot.hasChildren()) {
        return console.log('There are no notification tokens to send to.');
      }
      console.log('There are', tokensSnapshot.numChildren(), 'tokens to send notifications to.');
      //console.log('Fetched follower profile', follower);

      // Notification details.
      const payload = {
        notification: {
          title: 'Alguien tomo tu pedido!',
          //body: `${follower.displayName} is now following you.`,
          //icon: follower.photoURL
        }
      };

      // Listing all tokens as an array.
      tokens = Object.keys(tokensSnapshot.val());
      console.log(tokens);
      // Send notifications to all tokens.
      const response = await admin.messaging().sendToDevice(tokens, payload);
      // For each message check if there was an error.
      const tokensToRemove = [];
      response.results.forEach((result, index) => {
        const error = result.error;
        if (error) {
          console.error('Failure sending notification to', tokens[index], error);
          // Cleanup the tokens who are not registered anymore.
          if (error.code === 'messaging/invalid-registration-token' ||
              error.code === 'messaging/registration-token-not-registered') {
            tokensToRemove.push(tokensSnapshot.ref.child(tokens[index]).remove());
          }
        }
      });
      return Promise.all(tokensToRemove);
    });