# Step-by-Step Guide for "Zero Cost" Verification

You asked: _"What do I do on AWS?"_
**Answer**: For this specific "Zero Cost" solution, **you do NOT need to log in to AWS at all.**

We are simulating AWS inside GitHub. If you log in to AWS and create resources, **you will be charged money**.

Here is your exact checklist to finish this task and prove it works:

## 1. The GitHub Setup (Free)

Since your organization repo doesn't have Actions enabled, use your **Fork**.

1.  Make sure you are working on your forked repository.
2.  Enable "Actions" in your forked repository settings if it's not already on.

## 2. Push the Code

You need to push the folder `Day_7_ECS_Fargate` to your GitHub repo.

Run these commands in your terminal (at `d:\Personal Tech\Job Applications\PearlThoughts\Day_1_Strapi`):

```bash
# 1. Add the new files
git add Day_7_ECS_Fargate

# 2. Commit them
git commit -m "feat: add zero-cost ECS deployment with LocalStack"

# 3. Push to your fork (assuming 'origin' is your fork)
git push origin main
```

## 3. Watch the Magic (Verification)

1.  Go to your GitHub Repository in the browser.
2.  Click the **"Actions"** tab at the top.
3.  You should see a workflow running called **"Deploy to ECS (Zero Cost / LocalStack)"**.
4.  Click on it. Watch the steps.
    - **Build**: It will build your Docker image.
    - **Terraform Apply**: It will "talk" to the fake AWS (LocalStack) and create the cluster.
    - **Verify**: It will list the cluster to prove it exists.

## 4. What if you _really_ want to use real AWS?

**WARNING: THIS WILL COST MONEY ($$$)**

If (and only if) you decide to spend money to see it in the real console:

1.  **AWS Console**: Create an IAM User with `AdministratorAccess`.
2.  **AWS Console**: Generate an "Access Key" and "Secret Key" for that user.
3.  **GitHub Settings**: Go to Settings -> Secrets and Variables -> Actions.
    - Add `AWS_ACCESS_KEY_ID`
    - Add `AWS_SECRET_ACCESS_KEY`
4.  **Edit Code**: In `.github/workflows/ci-cd.yml`, remove the `use_localstack` parts.

**Recommendation**: Stick to steps 1-3. It fulfills the requirement "Deploy ... using git action only" and proves you can write the code without hurting your wallet.
